#include <cstdio>
#include <vector>

// #define __CL_ENABLE_EXCEPTIONS
#include <CL/cl.h>
#define DATA_SIZE (131072)
#define limbs_per_elem (12)

#include <libff/algebra/curves/mnt753/mnt4753/mnt4753_pp.hpp>
#include <libff/algebra/curves/mnt753/mnt6753/mnt6753_pp.hpp>
#include <libff/algebra/curves/mnt753/mnt4753/mnt4753_init.hpp>
#include <chrono> 

using namespace std::chrono; 
using namespace libff;
using namespace std;

#include <typeinfo>
#include <unistd.h>
#include <string.h>
#include <errno.h>

char *getcwd(char *buf, size_t size);


typedef struct _int768 {
  cl_uint v[24];
}int768;

void print(int768 v) {
  //gmp_printf("%Nd\n", this->data, n);
  mp_size_t size = 12;
  gmp_printf("gmp format: %Nu\n", &v, size);
  gmp_printf("standard format: %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu\n",
    v.v[23],v.v[22],v.v[21],v.v[20],v.v[19],v.v[18],v.v[17],v.v[16],v.v[15],v.v[14],v.v[13],v.v[12],v.v[11],v.v[10],v.v[9],v.v[8],v.v[7],v.v[6],v.v[5],v.v[4],v.v[3],v.v[2],v.v[1],v.v[0]);
}

Fq<mnt4753_pp> read_mnt4_fq(FILE* input) {
  // bigint<mnt4753_q_limbs> n;
  Fq<mnt4753_pp> x;
  fread((void *) x.mont_repr.data, libff::mnt4753_q_limbs * sizeof(mp_size_t), 1, input);
  return x;
}

void write_mnt4_fq(FILE* output, Fq<mnt4753_pp> x) {
  fwrite((void *) x.mont_repr.data, libff::mnt4753_q_limbs * sizeof(mp_size_t), 1, output);
}

Fq<mnt6753_pp> read_mnt6_fq(FILE* input) {
  // bigint<mnt4753_q_limbs> n;
  Fq<mnt6753_pp> x;
  fread((void *) x.mont_repr.data, libff::mnt6753_q_limbs * sizeof(mp_size_t), 1, input);
  return x;
}

void write_mnt6_fq(FILE* output, Fq<mnt6753_pp> x) {
  fwrite((void *) x.mont_repr.data, libff::mnt6753_q_limbs * sizeof(mp_size_t), 1, output);
}

Fq<mnt4753_pp> read_mnt4_fq_numeral(FILE* input) {
  // bigint<mnt4753_q_limbs> n;
  Fq<mnt4753_pp> x;
  fread((void *) x.mont_repr.data, libff::mnt4753_q_limbs * sizeof(mp_size_t), 1, input);
  auto b = Fq<mnt4753_pp>(x.mont_repr);
  return b;
}

void write_mnt4_fq_numeral(FILE* output, Fq<mnt4753_pp> x) {
  auto out_numeral = x.as_bigint();
  fwrite((void *) out_numeral.data, libff::mnt4753_q_limbs * sizeof(mp_size_t), 1, output);
}

Fq<mnt6753_pp> read_mnt6_fq_numeral(FILE* input) {
  // bigint<mnt4753_q_limbs> n;
  Fq<mnt6753_pp> x;
  fread((void *) x.mont_repr.data, libff::mnt6753_q_limbs * sizeof(mp_size_t), 1, input);
  auto b = Fq<mnt6753_pp>(x.mont_repr);
  return b;
}

void write_mnt6_fq_numeral(FILE* output, Fq<mnt6753_pp> x) {
  auto out_numeral = x.as_bigint();
  fwrite((void *) out_numeral.data, libff::mnt6753_q_limbs * sizeof(mp_size_t), 1, output);
}

void print_array(uint8_t* a) {
  for (int j = 0; j < 96; j++) {
    printf("%x ", ((uint8_t*)(a))[j]);
  }
  printf("\n");
}

// The actual code for doing Fq multiplication lives in libff/algebra/fields/fp.tcc
int main(int argc, char *argv[])
{
    // argv should be
    // { "main", "compute" or "compute-numeral", inputs, outputs }
    printf("Running mul on inputs... %s\n", argv[2]);
    printf("limb count %u\n", libff::mnt4753_q_limbs);

    // printf("size of int768 %d\n", sizeof(int768));
    // printf("size of mnt4753 mont repr %d\n", libff::mnt4753_q_limbs * sizeof(mp_size_t));
    mnt4753_pp::init_public_params();
    mnt6753_pp::init_public_params();

    size_t n;

    auto is_numeral = strcmp(argv[1], "compute-numeral") == 0;
    auto inputs = fopen(argv[2], "r");
    auto outputs = fopen(argv[3], "w");

    auto read_mnt4 = read_mnt4_fq;
    auto read_mnt6 = read_mnt6_fq;
    auto write_mnt4 = write_mnt4_fq;
    auto write_mnt6 = write_mnt6_fq;
    if (is_numeral) {
      read_mnt4 = read_mnt4_fq_numeral;
      read_mnt6 = read_mnt6_fq_numeral;
      write_mnt4 = write_mnt4_fq_numeral;
      write_mnt6 = write_mnt6_fq_numeral;

    }

    while (true) {
      printf("---- round ---- \n");
      size_t elts_read = fread((void *) &n, sizeof(size_t), 1, inputs);
      if (elts_read == 0) { break; }

      std::vector<Fq<mnt4753_pp>> x0;
      for (size_t i = 0; i < n; ++i) {
        x0.emplace_back(read_mnt4(inputs));
      }

      std::vector<Fq<mnt4753_pp>> x1;
      for (size_t i = 0; i < n; ++i) {
        x1.emplace_back(read_mnt4(inputs));
      }

      std::vector<Fq<mnt6753_pp>> y0;
      for (size_t i = 0; i < n; ++i) {
        y0.emplace_back(read_mnt6(inputs));
      }
      std::vector<Fq<mnt6753_pp>> y1;
      for (size_t i = 0; i < n; ++i) {
        y1.emplace_back(read_mnt6(inputs));
      }

      auto start = high_resolution_clock::now();
      for (size_t i = 0; i < n; ++i) {
        write_mnt4(outputs, x0[i] * x1[i]);
      }
      auto stop = high_resolution_clock::now();
      auto duration = duration_cast<microseconds>(stop - start); 
      cout << "Time taken by CPU function: "
        << duration.count() << " microseconds" << endl;

      for (size_t i = 0; i < n; ++i) {
        write_mnt6(outputs, y0[i] * y1[i]);
      }

      printf("mnt6753 mod:\n");
      y0[0].mod.print_hex();
      for(int i=0; i<11; i++) {
        //printf("%x\n", x0[0].mod.data[i]);
        cl_uint x;
        cl_uint y;
        x = (cl_uint)((y0[0].mod.data[i] & 0xFFFFFFFF00000000LL) >> 32);
        y = (cl_uint)(y0[0].mod.data[i] & 0xFFFFFFFFLL);
        gmp_printf("%Mx\n", y0[0].mod.data[i]);
        printf("%x\n", x);
        printf("%x\n", y);
      }
      mp_size_t siz = 1;
      gmp_printf("inverse 64bit: %Nu\n", &y0[0].inv, siz);

      // monty one 
      printf("mnt6753 ONE:\n");
      y0[0].one().mont_repr.print();

      printf("num bits %u\n", y0[123].num_bits);


      // OPENCL START

      char cwd[1024];
      if (getcwd(cwd, sizeof(cwd)) != NULL) {
         // printf("Current working dir: %s\n", cwd);
      } else {
         perror("getcwd() error");
         return 1;
      }

      FILE *fp;
      char *source_str;
      size_t source_size, program_size;

      fp = fopen("kernels/field.cl", "r");
      if (!fp) {
          fprintf(stderr, "could not open program file\n");
          exit(1);
      }

      char* program_source_code;
      size_t program_source_code_size;
      program_source_code = (char*)malloc(400000);
      program_source_code_size = fread(program_source_code, 1, 400000, fp);
      fclose(fp);

      int err;                            // error code returned from api calls
      char name[128];
        
      Fq<mnt4753_pp>* data_x0 = new Fq<mnt4753_pp>[n];              // original data set given to device
      Fq<mnt4753_pp>* data_x1 = new Fq<mnt4753_pp>[n];              // original data set given to device
      Fq<mnt4753_pp>* data_y0 = new Fq<mnt4753_pp>[n];              // original data set given to device
      Fq<mnt4753_pp>* data_y1 = new Fq<mnt4753_pp>[n];              // original data set given to device
      Fq<mnt4753_pp> results[n];           // results returned from device
      unsigned int correct;               // number of correct results returned

      size_t global;                      // global domain size for our calculation
      size_t local;                       // local domain size for our calculation
      cl_device_id device_id;             // compute device id 
      cl_context context;                 // compute context
      cl_command_queue commands;          // compute command queue
      cl_program program;                 // compute program
      cl_kernel kernel;                   // compute kernel
      cl_event event;                     // timing
      cl_ulong time_start;
      cl_ulong time_end;

      
      cl_mem input_x0;                       // device memory used for the input array
      cl_mem input_x1;                       // device memory used for the input array
      cl_mem output_x;                       // device memory used for the input array
      cl_mem output_y;                      // device memory used for the output array

      // Fill our data set with field inputs from param gen
      //
      unsigned int count = n;
      mp_size_t num = 1;
      for(int i = 0; i < count; i++) {
        memcpy(&data_x0[i], &x0[i].mont_repr.data, sizeof(int768));
      }
      printf("count %u\n", n);

      data_x0[0].mont_repr.print();

      for(int i = 0; i < count; i++) {
        memcpy(&data_x1[i], &x1[i].mont_repr.data, sizeof(int768));
      }
      
      // Connect to a compute device
      //

      /* get platform number of OpenCL */
      cl_uint  num_platforms = 0;
      clGetPlatformIDs (0, NULL, &num_platforms);
      printf("num_platforms: %d\n", (int)num_platforms);

      /* allocate a segment of mem space, so as to store supported platform info */
      cl_platform_id *platforms = (cl_platform_id *) malloc (num_platforms * sizeof (cl_platform_id));

      /* get platform info */
      clGetPlatformIDs (num_platforms, platforms, NULL);

      /* get device number on platform */
      cl_uint num_devices = 0;
      clGetDeviceIDs (platforms[0], CL_DEVICE_TYPE_GPU, 0, NULL, &num_devices);
      printf("num_devices: %d\n", (int)num_devices);

      /* allocate a segment of mem space, to store device info, supported by platform */
      cl_device_id *devices;
      devices = (cl_device_id *) malloc (num_devices * sizeof (cl_device_id));

      /* get device info */
      clGetDeviceIDs (platforms[0], CL_DEVICE_TYPE_GPU, num_devices, devices, NULL);

      // int gpu = 1;
      // err = clGetDeviceIDs(NULL, gpu ? CL_DEVICE_TYPE_GPU : CL_DEVICE_TYPE_CPU, 1, &device_id, NULL);
      // if (err != CL_SUCCESS)
      // {
      //     printf("Error: Failed to create a device group!\n");
      //     return EXIT_FAILURE;
      // }

      printf("Device id: %u\n", devices[0]);

      clGetDeviceInfo(devices[0], CL_DEVICE_NAME, 128, name, NULL);
      fprintf(stdout, "Created a dispatch queue using the %s\n", name);

      // Create a compute context 
      //
      printf("creating context\n");
      context = clCreateContext(0, num_devices, devices, NULL, NULL, &err);
      if (!context)
      {
          printf("Error: Failed to create a compute context!\n");
          return EXIT_FAILURE;
      }

      // Create a command commands
      //
      commands = clCreateCommandQueue(context, devices[0], CL_QUEUE_PROFILING_ENABLE, &err);
      if (!commands)
      {
          printf("Error: Failed to create a command commands!\n");
          return EXIT_FAILURE;
      }

      // Create the compute program from the source buffer
      //
      program = clCreateProgramWithSource(context, 1, (const char **) &program_source_code, &program_source_code_size, &err);
      if (!program)
      {
          printf("Error: Failed to create compute program!\n");
          return EXIT_FAILURE;
      }

      // Build the program executable
      //
      printf("building program\n");
      err = clBuildProgram(program, num_devices, devices, NULL, NULL, NULL);
      if (err != CL_SUCCESS)
      {
          size_t len;
          char buffer[2048];
          //std::cerr << getErrorString(err) << std::endl;
          printf("Error: Failed to build program executable!\n");
          printf ("Message: %s\n",strerror(err));
          clGetProgramBuildInfo(program, device_id, CL_PROGRAM_BUILD_LOG, sizeof(buffer), buffer, &len);
          exit(1);
      }

      // Create the compute kernel in the program we wish to run
      //
      kernel = clCreateKernel(program, "mul_field", &err);
      if (!kernel || err != CL_SUCCESS)
      {
          printf("Error: Failed to create compute kernel!\n");
          exit(1);
      }

      // Create the input and output arrays in device memory for our calculation
      //
      printf("creating buffer\n");
      input_x0 = clCreateBuffer(context,  CL_MEM_READ_ONLY,  sizeof(int768) * count, NULL, NULL);
      input_x1 = clCreateBuffer(context,  CL_MEM_READ_ONLY,  sizeof(int768) * count, NULL, NULL);
      output_x = clCreateBuffer(context, CL_MEM_WRITE_ONLY, sizeof(int768) * count, NULL, NULL);

      if (!input_x0 || !output_x)
      {
          printf("Error: Failed to allocate device memory!\n");
          exit(1);
      }

      // Write our data set into the input array in device memory 
      //
      start = high_resolution_clock::now();
      err = clEnqueueWriteBuffer(commands, input_x0, CL_TRUE, 0, sizeof(int768) * count, data_x0, 0, NULL, NULL);
      if (err != CL_SUCCESS)
      {
          printf("Error: Failed to write to source array!\n");
          exit(1);
      }
      err = clEnqueueWriteBuffer(commands, input_x1, CL_TRUE, 0, sizeof(int768) * count, data_x1, 0, NULL, NULL);
      if (err != CL_SUCCESS)
      {
          printf("Error: Failed to write to source array!\n");
          exit(1);
      }
      stop = high_resolution_clock::now();
      duration = duration_cast<microseconds>(stop - start); 
      cout << "Time taken by GPU write function: "
        << duration.count() << " microseconds" << endl;

      // Set the arguments to our compute kernel
      //
      err = 0;
      err  = clSetKernelArg(kernel, 0, sizeof(cl_mem), &input_x0);
      err  = clSetKernelArg(kernel, 1, sizeof(cl_mem), &input_x1);
      err |= clSetKernelArg(kernel, 2, sizeof(cl_mem), &output_x);
      err |= clSetKernelArg(kernel, 3, sizeof(unsigned int), &count);
      if (err != CL_SUCCESS)
      {
          printf("Error: Failed to set kernel arguments! %d\n", err);
          exit(1);
      }

      // Get the maximum work group size for executing the kernel on the device
      //
      err = clGetKernelWorkGroupInfo(kernel, devices[0], CL_KERNEL_WORK_GROUP_SIZE, sizeof(local), &local, NULL);
      if (err != CL_SUCCESS)
      {
          printf("Error: Failed to retrieve kernel work group info! %d\n", err);
          exit(1);
      }

      printf("Max work size: %u\n", local);

      // Execute the kernel over the entire range of our 1d input data set
      // using the maximum number of work group items for this device
      //
      global = count;
      printf("queueing kernel\n");
      err = clEnqueueNDRangeKernel(commands, kernel, 1, NULL, &global, &local, 0, NULL, &event);
      if (err)
      {
          printf("Error: Failed to execute kernel!\n");
          return EXIT_FAILURE;
      }

      clWaitForEvents(1, &event);
      clFinish(commands);

      // Time kernel execution time without read/write
      //
      clGetEventProfilingInfo(event, CL_PROFILING_COMMAND_START, sizeof(time_start), &time_start, NULL);
      clGetEventProfilingInfo(event, CL_PROFILING_COMMAND_END, sizeof(time_end), &time_end, NULL);

      double nanoSeconds = time_end-time_start;
      printf("OpenCl Execution time is: %0.3f milliseconds \n",nanoSeconds / 1000000.0);

      // Read back the results from the device to verify the output
      //
      start = high_resolution_clock::now();
      err = clEnqueueReadBuffer( commands, output_x, CL_TRUE, 0, sizeof(int768) * count, results, 0, NULL, NULL );  
      if (err != CL_SUCCESS)
      {
          printf("Error: Failed to read output array! %d\n", err);
          exit(1);
      }
      stop = high_resolution_clock::now();
      duration = duration_cast<microseconds>(stop - start); 
      cout << "Time taken by GPU read function: "
        << duration.count() << " microseconds" << endl;
      // Validate our results
      //
      printf("Kernel Result \n");
      //print(results[1014]);
      results[1013].mont_repr.print();
      printf("CPU Result\n");
      Fq<mnt4753_pp> tt = x0[1013] * x1[1013];
      tt.mont_repr.print();
      correct = 0;
      int bad = 0;
      for(int i = 0; i < count; i++)
      {
          Fq<mnt4753_pp> mul = x0[i] * x1[i];
          if(results[i] == mul) {
            correct++;
          } else if(i <1017) {
           bad = i;
          }
      }
      
      // Print a brief summary detailing the results
      //
      printf("Computed '%d/%d' correct mnt4753 values!\n", correct, count);
      printf("last bad output %d\n", bad);
      //x0[1014].mont_repr.print();
      //x1[1014].mont_repr.print();
      // Shutdown and cleanup
      //
      clReleaseMemObject(input_x0);
      clReleaseMemObject(input_x1);
      clReleaseMemObject(output_x);
      clReleaseProgram(program);
      clReleaseKernel(kernel);
      clReleaseCommandQueue(commands);
      clReleaseContext(context);

      // OPENCL END
      //break;
    }

    fclose(outputs);

    return 0;
}
