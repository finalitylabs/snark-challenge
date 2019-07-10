typedef struct {
  long v[12];
} int768;

void print(int768 v) {
  printf("%u %u %u %u %u %u %u %u %u %u %u %u\n",
    v.v[11],v.v[10],v.v[9],v.v[8],v.v[7],v.v[6],v.v[5],v.v[4],v.v[3],v.v[2],v.v[1],v.v[0]);
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
    __global int768* input_x,
    __global int768* input_y,
    __global int768* output,
    const unsigned int count)
{
    int i = get_global_id(0);
    print(input_x[i]);
    if(i < count)
        output[i].v[0] = input_x[i].v[0] * input_y[i].v[0];
}
