// FinalityLabs - 2019
// fixed 768 size prime-field arithmetic library (add, sub, mul, pow)
// Montgomery reduction parameters:
// B = 2^32 (Because our digits are uint32)


typedef uint uint32;
typedef ulong uint64;

typedef uint32 limb;
typedef uint64 limb2;

typedef struct {
  limb v[24];
} int768;

#define FIELD_LIMBS (24)
#define LIMB_BITS (32)
#define LIMB_MAX (0xffffffff)

// Montgomery form of 1 = (1 * R mod P)
//
#define mnt4753_ONE ((int768){0x43ed2b00,0x00000000,0x43ec9f00,0x00000000,0x43ecc800,0x00000000,0x43ec3c00,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x98a8ecab,0xd9dc6f42}) // removed 6 left padded bytes
//
//#define mnt6753_ONE ((int768){0x43ed2b0000000000,0x43ec9f0000000000,0x43ecc80000000000,0x43ec3c0000000000,0x0000000000000000,0x0000000000000000,0x0000000000000000,0x0000000000000000,0x0000000000000000,0x0000000000000000,0x0000000000000000,0xb99680147fff6f42})

#define mnt4753_ZERO (0)
#define mnt6753_ZERO (0)

#define mnt4753_INV_Fr ((ulong)0xc90776e23fffffff)
#define mnt4753_INV_Fq ((uint)0xe45e7fff)
#define mnt6753_INV_Fr ((ulong)0xf2044cfbe45e7fff)
#define mnt6753_INV_Fq ((ulong)0xc90776e23fffffff)

//integer_repr
//#define mnt4753_Q ((int768){3798144713,1644726289,1209104241,1725357052,3416796615,3623268187,4101813835,3963192318,3700618320,1992740072,2456604845,2077153419,4089149708,47111175,2261968297,3206296621,1718926137,710029764,137940322,318271950,2854819438,2295312200,837751343,32769})
// signed two's compliment
//#define mnt4753_Q ((int768){0x01C4C62D,0x92C41110,0x229022EE,0xE2CDADB7,0xF997505B,0x8FAFED5E,0xB7E8F96C,0x97D87307,0xFDB925E8,0xA0ED8D99,0xD124D9A1,0x5AF79DB1,0x17E776F2,0x18059DB8,0x0F0DA5CB,0x537E3868,0x5ACCE976,0x7254A463,0x8810719A,0xC425F0E3,0x9D54522C,0xDD119F5E,0x9063DE24,0x5E80010000})

//#define mnt6753_Q ((int768){0x01C4C62D92C41110,0x229022EEE2CDADB7,0xF997505B8FAFED5E,0xB7E8F96C97D87307,0xFDB925E8A0ED8D99,0xD124D9A15AF79DB2,0x6C5C28C859A99B3E,0xEBCA9429212636B9,0xDFF97634993AA4D6,0xC381BC3F0057974E,0xA099170FA13A4FD9,0x0776E240000001})

//#define mnt4753_Q ((int768){0x1c4c6,0x2d92c411,0x10229022,0xeee2cdad,0xb7f99750,0x5b8fafed,0x5eb7e8f9,0x6c97d873,0x07fdb925,0xe8a0ed8d,0x99d124d9,0xa15af79d,0xb117e776,0xf218059d,0xb80f0da5,0xcb537e38,0x685acce9,0x767254a4,0x63881071,0x9ac425f0,0xe39d5452,0x2cdd119f,0x5e9063de,0x245e8001})
//#define mnt4753_Q ((int768){0x5e9063de,0x245e8001,0xe39d5452,0x2cdd119f,0x63881071,0x9ac425f0,0x685acce9,0x767254a4,0xb80f0da5,0xcb537e38,0xb117e776,0xf218059d,0x99d124d9,0xa15af79d,0x7fdb925,0xe8a0ed8d,0x5eb7e8f9,0x6c97d873,0xb7f99750,0x5b8fafed,0x10229022,0xeee2cdad,0x1c4c6,0x2d92c411})

#define mnt4753_Q ((int768){0x245e8001,0x5e9063de,0x2cdd119f,0xe39d5452,0x9ac425f0,0x63881071,0x767254a4,0x685acce9,0xcb537e38,0xb80f0da5,0xf218059d,0xb117e776,0xa15af79d,0x99d124d9,0xe8a0ed8d,0x07fdb925,0x6c97d873,0x5eb7e8f9,0x5b8fafed,0xb7f99750,0xeee2cdad,0x10229022,0x2d92c411,0x1c4c6})
//#define mnt4753_Q ((int768){0x00000001,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000,0x00000000})

//#define mnt4753_R ((int768){0x01C4C62D92C41110,0x229022EEE2CDADB7,0xF997505B8FAFED5E,0xB7E8F96C97D87307,0xFDB925E8A0ED8D99,0xD124D9A15AF79DB2,0x6C5C28C859A99B3E,0xEBCA9429212636B9,0xDFF97634993AA4D6,0xC381BC3F0057974E,0xA099170FA13A4FD9,0x0776E24000000100}) // one extra byte padded 00 
//#define mnt6753_R ((int768){0x01C4C62D92C41110,0x229022EEE2CDADB7,0xF997505B8FAFED5E,0xB7E8F96C97D87307,0xFDB925E8A0ED8D99,0xD124D9A15AF79DB1,0x17E776F218059DB8,0x0F0DA5CB537E3868,0x5ACCE9767254A463,0x8810719AC425F0E3,0x9D54522CDD119F5E,0x9063DE245E800100})

void print(int768 v) {
  printf("%u %u %u %u %u %u %u %u %u %u %u %u %u %u %u %u %u %u %u %u %u %u %u %u\n",
    v.v[23],v.v[22],v.v[21],v.v[20],v.v[19],v.v[18],v.v[17],v.v[16],v.v[15],v.v[14],v.v[13],v.v[12], v.v[11],v.v[10],v.v[9],v.v[8],v.v[7],v.v[6],v.v[5],v.v[4],v.v[3],v.v[2],v.v[1],v.v[0]);
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

// Adds `num` to `i`th digit of `res` and propagates carry in case of overflow
void add_digit(limb *res, limb num) {
  limb old = *res;
  *res += num;
  if(*res < old) {
    res++;
    while(++(*(res++)) == 0);
  }
}

limb mac_with_carry(limb a, limb b, limb c, limb *carry) {
  limb lo = a * b;
  limb hi = mul_hi(a, b);
  hi += lo + c < lo; lo += c;
  hi += lo + *carry < lo; lo += *carry;
  *carry = hi;
  return lo;
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
  bool carry = 0;
  for(int i = 0; i < FIELD_LIMBS; i++) {
    limb2 sum = (limb2)a.v[i] + b.v[i] + carry;
    a.v[i] = sum & LIMB_MAX;
    carry = sum >> LIMB_BITS;
    //"this implementation fails for some inputs"
    //ulong old = a.v[i];
    //a.v[i] += b.v[i] + carry;
    //carry = carry ? old >= a.v[i] : old > a.v[i];
  }
  return a;
}

// Normal subtraction
int768 int768_sub_(int768 a, int768 b) {
  bool borrow = 0;
  for(int i = 0; i < FIELD_LIMBS; i++) {
    limb2 sub = (limb2)a.v[i] - b.v[i] - borrow;
    a.v[i] = sub & LIMB_MAX;
    borrow = (sub >> LIMB_BITS) & 1;
    // "still works for sub but removing for consistency"
    //ulong old = a.v[i];
    //a.v[i] -= b.v[i] + borrow;
    //borrow = borrow ? old <= a.v[i] : old < a.v[i];
  }
  return a;
}

int768 int768_reduce(ulong *limbs) {
  // Montgomery reduction
  bool carry2 = 0;
  for(uchar i = 0; i < FIELD_LIMBS; i++) {
    limb u = mnt4753_INV_Fq * limbs[i];
    limb carry = 0;
    for(uchar j = 0; j < FIELD_LIMBS; j++) {
      limb2 product = (limb2)u * mnt4753_Q.v[j] + limbs[i + j] + carry;
      limbs[i + j] = product & LIMB_MAX;
      carry = product >> LIMB_BITS;
    }
    limb2 sum = (limb2)limbs[i + FIELD_LIMBS] + carry + carry2;
    limbs[i + FIELD_LIMBS] = sum & LIMB_MAX;
    carry2 = sum >> LIMB_BITS;
  }

  // Divide by R
  int768 result;
  // this breaks amd compiler
  for(uchar i = 0; i < FIELD_LIMBS; i++) result.v[i] = limbs[i+FIELD_LIMBS];

  if(int768_gte(result, mnt4753_Q))
    result = int768_sub_(result, mnt4753_Q);

  return result;
}

// Modular multiplication
int768 int768_mul(int768 a, int768 b) {
  // long multiplication
  limb res[FIELD_LIMBS * 2] = {0};
  for(uint32 i = 0; i < FIELD_LIMBS; i++) {
    limb carry = 0;
    for(uint32 j = 0; j < FIELD_LIMBS; j++) {
      limb2 product = (limb2)a.v[i] * b.v[j] + res[i + j] + carry;
      res[i + j] = product & LIMB_MAX;
      carry = product >> LIMB_BITS;
      //res[i + j] = mac_with_carry(a.v[i], b.v[j], res[i + j], &carry);
    }
    res[i + FIELD_LIMBS] = carry;
  }
  // this breaks amd compiler
  //return int768_reduce(res);

  bool carry2 = 0;
  for(uchar i = 0; i < FIELD_LIMBS; i++) {
    limb u = mnt4753_INV_Fq * res[i];
    limb carry = 0;
    for(uchar j = 0; j < FIELD_LIMBS; j++) {
      limb2 product = (limb2)u * mnt4753_Q.v[j] + res[i + j] + carry;
      res[i + j] = product & LIMB_MAX;
      carry = product >> LIMB_BITS;
    }
    limb2 sum = (limb2)res[i + FIELD_LIMBS] + carry + carry2;
    res[i + FIELD_LIMBS] = sum & LIMB_MAX;
    carry2 = sum >> LIMB_BITS;
  }

  // Divide by R
  int768 result;
  for(uchar i = 0; i < FIELD_LIMBS; i++) result.v[i] = res[i+FIELD_LIMBS];

  if(int768_gte(result, mnt4753_Q))
    result = int768_sub_(result, mnt4753_Q);

  return result;
}

// Modular negation
int768 int768_neg(int768 a) {
  return int768_sub_(mnt4753_Q, a);
}

// Modular subtraction
int768 int768_sub(int768 a, int768 b) {
  int768 res = int768_sub_(a, b);
  if(!int768_gte(a, b)) res = int768_add_(res, mnt4753_Q);
  return res;
}

// Modular addition
int768 int768_add(int768 a, int768 b) {
  //return int768_sub(a, int768_neg(b));
  int768 tmp = int768_neg(b);
  int768 res = int768_sub_(a, tmp);
  if(!int768_gte(a, tmp)) res = int768_add_(res, mnt4753_Q);
  return res;
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

// Fq2 arithmetics
//
typedef struct {
  int768 c0;
  int768 c1;
} Fq2;

#define Fq2_ZERO ((Fq2){mnt4753_ZERO, mnt4753_ZERO})
#define Fq2_ONE ((Fq2){mnt4753_ONE, FIELD_ZERO})


bool Fq2_eq(Fq2 a, Fq2 b) {
  return int768_eq(a.c0, b.c0) && int768_eq(a.c1, b.c1);
}
Fq2 Fq2_neg(Fq2 a) {
  a.c0 = int768_neg(a.c0);
  a.c1 = int768_neg(a.c1);
  return a;
}
Fq2 Fq2_sub(Fq2 a, Fq2 b) {
  a.c0 = int768_sub(a.c0, b.c0);
  a.c1 = int768_sub(a.c1, b.c1);
  return a;
}
Fq2 Fq2_add(Fq2 a, Fq2 b) {
  a.c0 = int768_add(a.c0, b.c0);
  a.c1 = int768_add(a.c1, b.c1);
  return a;
}
Fq2 Fq2_mul(Fq2 a, Fq2 b) {
  int768 aa = int768_mul(a.c0, b.c0);
  int768 bb = int768_mul(a.c1, b.c1);
  int768 o = int768_add(b.c0, b.c1);
  a.c1 = int768_add(a.c1, a.c0);
  a.c1 = int768_mul(a.c1, o);
  a.c1 = int768_sub(a.c1, aa);
  a.c1 = int768_sub(a.c1, bb);
  a.c0 = int768_sub(aa, bb);
  return a;
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

__kernel void mul_fq2(
    __global Fq2* input_x,
    __global Fq2* input_y,
    __global Fq2* output,
    const unsigned int count)
{
    int i = get_global_id(0);
    output[i] = Fq2_mul(input_x[i], input_y[i]);
    //output[i] = Fq2_add(input_x0[i], input_x1[i]);
    //output[i] = Fq2_sub(input_x0[i], input_x1[i]);
    //output[i] = Fq2_neg(input_x1[i]);
    //output[i] = mnt4753_Q;
}
