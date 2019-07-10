// FinalityLabs - 2019
// fixed 768 size prime-field arithmetic library (add, sub, mul, pow)
// Montgomery reduction parameters:
// B = 2^32 (Because our digits are uint32)

typedef struct {
  long v[12];
} int768;

typedef uint uint32;

#define FIELD_LIMBS (12)

// Montgomery form of 1 = (1 * R mod P)
#define mnt4753_ONE ((int768){0xfffffffe,0x00000001,0x00034802,0x5884b7fa,0xecbc4ff5,0x998c4fef,0xacc5056f,0x1824b159, 0x1824b159, 0x1824b159, 0x1824b159, 0x1824b159})
#define mnt6753_ONE ((int768){0xfffffffe,0x00000001,0x00034802,0x5884b7fa,0xecbc4ff5,0x998c4fef,0xacc5056f,0x1824b159, 0x1824b159, 0x1824b159, 0x1824b159, 0x1824b159})

#define mnt4753_ZERO (0)
#define mnt6753_ZERO (0)

#define mnt4753_INV_Fp ((long)0xc90776e23fffffff)
#define mnt4753_INV_Fq ((long)0xf2044cfbe45e7fff)
#define mnt6753_INV_Fp ((long)0xf2044cfbe45e7fff)
#define mnt6753_INV_Fq ((long)0xc90776e23fffffff)

#define mnt4753_Q ((int768){0x01C4C62D92C41110,0x229022EEE2CDADB7,0xF997505B8FAFED5E,0xB7E8F96C97D87307,0xFDB925E8A0ED8D99,0xD124D9A15AF79DB1,0x17E776F218059DB8,0x0F0DA5CB537E3868,0x5ACCE9767254A463,0x8810719AC425F0E3,0x9D54522CDD119F5E,0x9063DE245E800100})
#define mnt6753_Q ((int768){0x01C4C62D92C41110,0x229022EEE2CDADB7,0xF997505B8FAFED5E,0xB7E8F96C97D87307,0xFDB925E8A0ED8D99,0xD124D9A15AF79DB2,0x6C5C28C859A99B3E,0xEBCA9429212636B9,0xDFF97634993AA4D6,0xC381BC3F0057974E,0xA099170FA13A4FD9,0x0776E24000000100})

#define mnt4753_P ((int768){0x01C4C62D92C41110,0x229022EEE2CDADB7,0xF997505B8FAFED5E,0xB7E8F96C97D87307,0xFDB925E8A0ED8D99,0xD124D9A15AF79DB2,0x6C5C28C859A99B3E,0xEBCA9429212636B9,0xDFF97634993AA4D6,0xC381BC3F0057974E,0xA099170FA13A4FD9,0x0776E24000000100}) // one extra byte padded 00 
#define mnt6753_P ((int768){0x01C4C62D92C41110,0x229022EEE2CDADB7,0xF997505B8FAFED5E,0xB7E8F96C97D87307,0xFDB925E8A0ED8D99,0xD124D9A15AF79DB1,0x17E776F218059DB8,0x0F0DA5CB537E3868,0x5ACCE9767254A463,0x8810719AC425F0E3,0x9D54522CDD119F5E,0x9063DE245E800100})

void print(int768 v) {
  printf("%u %u %u %u %u %u %u %u %u %u %u %u\n",
    v.v[11],v.v[10],v.v[9],v.v[8],v.v[7],v.v[6],v.v[5],v.v[4],v.v[3],v.v[2],v.v[1],v.v[0]);
}

// Adds `num` to `i`th digit of `res` and propagates carry in case of overflow
void add_digit(long *res, long num) {
  long old = *res;
  *res += num;
  if(*res < old) {
    res++;
    while(++(*(res++)) == 0);
  }
}

long mac_with_carry(long a, long b, long c, long *carry) {
  long lo = a * b;
  long hi = mul_hi(a, b);
  hi += lo + c < lo; lo += c;
  hi += lo + *carry < lo; lo += *carry;
  *carry = hi;
  return lo;
}

// Greater than or equal
bool int768_gte(int768 a, int768 b) {
  for(int i = FIELD_LIMBS - 1; i >= 0; i--){
    if(a.v[i] > b.v[i])
      return true;
    if(a.v[i] < b.v[i])
      return false;
  }
  return true;
}

// Equals
bool int768_eq(int768 a, int768 b) {
  for(int i = 0; i < FIELD_LIMBS; i++)
    if(a.v[i] != b.v[i])
      return false;
  return true;
}

// Normal addition
int768 int768_add_(int768 a, int768 b) {
  uint32 carry = 0;
  for(int i = 0; i < FIELD_LIMBS; i++) {
    long old = a.v[i];
    a.v[i] += b.v[i] + carry;
    carry = carry ? old >= a.v[i] : old > a.v[i];
  }
  return a;
}

// Normal subtraction
int768 int768_sub_(int768 a, int768 b) {
  uint32 borrow = 0;
  for(int i = 0; i < FIELD_LIMBS; i++) {
    long old = a.v[i];
    a.v[i] -= b.v[i] + borrow;
    borrow = borrow ? old <= a.v[i] : old < a.v[i];
  }
  return a;
}

// Modular multiplication
int768 int768_mul(int768 a, int768 b) {
  // Long multiplication
  long res[FIELD_LIMBS * 2] = {0};
  for(uint32 i = 0; i < FIELD_LIMBS; i++) {
    long carry = 0;
    for(uint32 j = 0; j < FIELD_LIMBS; j++) {
      res[i + j] = mac_with_carry(a.v[i], b.v[j], res[i + j], &carry);
    }
    res[i + FIELD_LIMBS] = carry;
  }

  // Montgomery reduction
  for(uint32 i = 0; i < FIELD_LIMBS; i++) {
    long u = mnt4753_INV_Fp * res[i];
    long carry = 0;
    for(uint32 j = 0; j < FIELD_LIMBS; j++)
      res[i + j] = mac_with_carry(u, mnt4753_P.v[j], res[i + j], &carry);
    add_digit(res + i + FIELD_LIMBS, carry);
  }

  // Divide by R
  int768 result;
  for(int i = 0; i < FIELD_LIMBS; i++) result.v[i] = res[i+FIELD_LIMBS];

  if(int768_gte(result, mnt4753_P))
    result = int768_sub_(result, mnt4753_P);

  return result;
}

// Modular negation
int768 int768_neg(int768 a) {
  return int768_sub_(mnt4753_P, a);
}

// Modular subtraction
int768 int768_sub(int768 a, int768 b) {
  int768 res = int768_sub_(a, b);
  if(!int768_gte(a, b)) res = int768_add_(res, mnt4753_P);
  return res;
}

// Modular addition
int768 int768_add(int768 a, int768 b) {
  return int768_sub(a, int768_neg(b));
}

// Modular exponentiation
int768 int768_pow(int768 base, uint32 exponent) {
  int768 res = mnt4753_ONE;
  while(exponent > 0) {
    if (exponent & 1)
      res = int768_mul(res, base);
    exponent = exponent >> 1;
    base = int768_mul(base, base);
  }
  return res;
}

int768 int768_pow_cached(__global int768 *bases, uint32 exponent) {
  int768 res = mnt4753_ONE;
  uint32 i = 0;
  while(exponent > 0) {
    if (exponent & 1)
      res = int768_mul(res, bases[i]);
    exponent = exponent >> 1;
    i++;
  }
  return res;
}



__kernel void square(
   __global float* input,
   __global float* output,
   const unsigned int count)
{
   int i = get_global_id(0);
   if(i < count)
       output[i] = input[i] * input[i];
}

__kernel void mul_field(
    __global int768* input_x0,
    __global int768* input_x1,
    __global int768* output,
    const unsigned int count)
{
    int i = get_global_id(0);
    // print(input_x[i]);
    // printf("%u",i);
    output[i].v[0] = input_x0[i].v[0] * input_x1[i].v[0];
}
