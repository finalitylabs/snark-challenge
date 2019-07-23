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
#define mnt4753_ONE ((int768){{0xd9dc6f42,0x98a8ecab,0x5a034686,0x91cd31c6,0xcd14572e,0x97c3e4a0,0xc788b601,0x79589819,0x2108976f,0xed269c94,0xcf031d68,0x1e0f4d8a,0x13338559,0x320c3bb7,0xd2f00a62,0x598b4302,0xfd8ca621,0x4074c9cb,0x3865e88c,0xfa47edb,0x1ff9a195,0x95455fb3,0x9ec8e242,0x7b47}}) // removed 6 left padded bytes

#define mnt4753_ZERO ((int768){{0}})

#define mnt4753_INV_Fq ((uint){{0xe45e7fff}})

#define mnt4753_Q ((int768){{0x245e8001,0x5e9063de,0x2cdd119f,0xe39d5452,0x9ac425f0,0x63881071,0x767254a4,0x685acce9,0xcb537e38,0xb80f0da5,0xf218059d,0xb117e776,0xa15af79d,0x99d124d9,0xe8a0ed8d,0x07fdb925,0x6c97d873,0x5eb7e8f9,0x5b8fafed,0xb7f99750,0xeee2cdad,0x10229022,0x2d92c411,0x1c4c6}})

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

// Montgomery non_residue
#define non_residue ((int768){{0xa3162657,0xa4e2d91f,0xb935ff7,0xbc938a1c,0x99bbfb8a,0x8a5a6ad5,0xbe9a4027,0xf06f5292,0x4b7535ff,0xe2c8ca94,0xace06d7a,0x737f39a7,0x158cdead,0xbd2b99bf,0xfc4dbe53,0x74193bb2,0x9a5ce658,0x29c6846f,0xca7dbf57,0xa36dab30,0xd304cb88,0x641e2baf,0x877b312e,0xf450}});
// Integer non_residue
//#define non_residue ((int768){{0xD}});

bool Fq2_eq(Fq2 a, Fq2 b) {
  return 
  int768_eq(a.c0, b.c0) && int768_eq(a.c1, b.c1);
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

Fq2 Fq2_mul(Fq2 _a, Fq2 _b) {
  int768 residue = non_residue;
  //print(residue);
  int768 A = _b.c0;
  int768 a = _a.c0;
  int768 B = _b.c1;
  int768 b = _a.c1;

  //  const my_Fp
  //      &A = other.c0, &B = other.c1,
  //      &a = this->c0, &b = this->c1;
  //  const my_Fp aA = a * A;
  //  const my_Fp bB = b * B;


  int768 aA = int768_mul(a, A);
  int768 bB = int768_mul(b, B);

  Fq2 res = Fq2_ZERO;

  //res.c0 = int768_add(aa, int768_mul(residue, bb));
  //res.c0 = int768_add(aA, int768_mul(residue, bB));
  res.c0 = int768_add(int768_mul(_a.c0, _b.c0), int768_mul(residue, int768_mul(_a.c1, _b.c1)));
  
  
  // Sub(Sub(Mul(Add(x.a, x.b), Add(y.a, y.b)), A), B)
  //return Fp2_model<n,modulus>(aA + non_residue * bB,
  //                            (a + b)*(A+B) - aA - bB);

  int768 v4 = int768_add(a, b);
  int768 v3 = int768_add(A, B);
  int768 v2 = int768_mul(v4, v3);
  int768 v1 = int768_sub(v2, aA);
  int768 v0 = int768_sub(v1, bB);
  
  //res.c1 = v0;
  res.c1 = int768_mul(int768_add(_a.c0, _a.c1), int768_add(_b.c0, _b.c1));
  res.c1 = int768_sub(res.c1, aA);
  res.c1 = int768_sub(res.c1, bB);
  //res.c1 = int768_sub(res.c1, int768_mul(a, A));
  return res;
}

// Qubic arithmetics
//

// EC arithmetics
//

// Kernels
//


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
    Fq2 res = Fq2_ZERO;
    res.c0 = non_residue;
    //output[i] = res;
    output[i] = Fq2_mul(input_x[i], input_y[i]);
    //output[i] = Fq2_add(input_x[i], input_y[i]);
    //output[i] = Fq2_sub(input_x[i], input_y[i]);
    //output[i] = Fq2_neg(input_x[i]);
    //output[i].c0 = mnt4753_Q;
}
