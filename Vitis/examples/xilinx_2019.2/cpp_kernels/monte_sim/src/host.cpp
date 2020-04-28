// Implement a Exponentiation Function


#include "xcl2.hpp"
// #include "hls_math.h"
#include <algorithm>
#include <cstdio>
#include <random>
#include <vector>
// #include <bits/stdc++.h>
#include <cmath>
#include "ap_fixed.h"

using std::mt19937;
using std::generate;
using std::uniform_real_distribution;
using std::vector;

#define DATA_SIZE 4096


// typedef ap_fixed<16,7,AP_RND,AP_SAT> fix_type;
typedef ap_fixed<31,15> red_fix_type;

float gen_random() {
    std::random_device seed;
    static mt19937 re (seed());
    static std::uniform_real_distribution<float> unif(-9.0, 9.0);
    return unif(re);
}

float phi(float x) {
    // constants
    float a1 =  0.254829592;
    float a2 = -0.284496736;
    float a3 =  1.421413741;
    float a4 = -1.453152027;
    float a5 =  1.061405429;
    float p  =  0.3275911;

    // Save the sign of x
    int sign = 1;
    if (x < 0)
        sign = -1;
    
    x = fabs(x)/sqrt(2.0);

    // A&S formula 7.1.26
    float t = 1.0/(1.0 + p*x);
    float y = 1.0 - (((((a5*t + a4)*t) + a3)*t + a2)*t + a1)*t*exp(-x*x);

    return 0.5*(1.0 + sign*y);
}

red_fix_type rand_fix_gen() {
    float x = gen_random();
    float y = phi(x);

    // bitset<BIT_SET> bset1;
    red_fix_type o = static_cast<red_fix_type>(y);
    // fix_type out = o.range(24, 8);

    return o;
}


int main(int argc, char **argv) {
    if (argc != 2) {
        std::cout << "Usage: " << argv[0] << " <XCLBIN File" << std::endl;
        return EXIT_FAILURE;
    }

    std::string binaryFile = argv[1];
    size_t vector_size_bytes = sizeof(red_fix_type) * DATA_SIZE;
    cl_int err;
    cl::Context context;
    cl::Kernel kernel_monte_sim;
    cl::CommandQueue q;

    std::vector<red_fix_type, aligned_allocator<red_fix_type>> source_in1(DATA_SIZE);
    //std::vector<float, aligned_allocator<float>> source_sw(DATA_SIZE);  
    std::vector<red_fix_type, aligned_allocator<red_fix_type>> source_hw_results(DATA_SIZE);
    std::vector<float, aligned_allocator<float>> source_sw_results(DATA_SIZE);

    // Create the test data
    std::generate(source_in1.begin(), source_in1.end(), rand_fix_gen);
    // std::generate(source_sw.begin(), source_in_sw.end(), rand_fl_gen);

    float t = 0.5;
    float so = 50.0;
    float r = 0.05;
    float sig = 0.2;
    
    for (int i = 0; i < DATA_SIZE; i++) {
        
        red_fix_type x = source_in1[i];
        float x1 = static_cast<float>(x);
       
        // float z = exp(x1); 
        float z = so * exp( (r - ( pow(sig , 2) / 2 ) * t) + ( x1 * sig * sqrt(t)) );

        source_sw_results[i] = z;
        source_hw_results[i] = 0;
    }

    

    // -------------------------------------------------------------------------
    // OpenCL Host Area Start
    auto devices = xcl::get_xil_devices();
    auto fileBuf = xcl::read_binary_file(binaryFile);
    cl::Program::Binaries bins{{fileBuf.data(), fileBuf.size()}};
    int valid_device = 0;
    for (unsigned int i = 0; i < devices.size(); i++) {
        auto device = devices[i];
        // Create Context and Command Queue
        OCL_CHECK(err, context = cl::Context({device}, NULL, NULL, NULL, &err));
        OCL_CHECK(err, 
                 q = cl::CommandQueue(
                     context, {device}, CL_QUEUE_PROFILING_ENABLE, &err));

        std::cout << "Trying to program device[" << i
                  << "]: " << device.getInfo<CL_DEVICE_NAME>() << std::endl;
        OCL_CHECK(err,
                    cl::Program program(context, {device}, bins, NULL, &err));
        if (err != CL_SUCCESS) {
            std::cout << "Faied to program device [" << i
                      << "] with xclbin file!\n";
        } else {
            std::cout << "Device[" << i << "]: program successful!\n";
            OCL_CHECK(err, kernel_monte_sim = cl::Kernel(program, "monte_sim", &err));
            valid_device++;
            break;
        }
    }
    if (valid_device == 0) {
        std::cout << "Failed to program any device found, exit!\n";
        exit(EXIT_FAILURE);
    }

    // Allocate Buffer in Global Memory
    // Buffers are allocated using CL_MEM_USE_HOST_PTR for efficient mem
    // and Device-to-host communication
    OCL_CHECK(err,
                cl::Buffer buffer_in1(context,
                                    CL_MEM_USE_HOST_PTR | CL_MEM_READ_ONLY,
                                    vector_size_bytes,
                                    source_in1.data(),
                                    &err));
/*    OCL_CHECK(err,
                cl::Buffer buffer_in2(context,
                                    CL_MEM_USE_HOST_PTR | CL_MEM_READ_ONLY,
                                    vector_size_bytes,
                                    source_in2.data(),
                                    &err));
*/

    OCL_CHECK(err,
                cl::Buffer buffer_output(context,
                                        CL_MEM_USE_HOST_PTR | CL_MEM_WRITE_ONLY,
                                        vector_size_bytes,
                                        source_hw_results.data(),
                                        &err));

    red_fix_type scalar_arg_time = 0.5;
    red_fix_type scalar_arg_so = 50.0;
    red_fix_type scalar_arg_rate = 0.05;
    red_fix_type scalar_arg_sigma = 0.2;

    int size = DATA_SIZE;
    int scalar_size = sizeof(red_fix_type);

    OCL_CHECK(err, err = kernel_monte_sim.setArg(0, scalar_size, &scalar_arg_time));
    OCL_CHECK(err, err = kernel_monte_sim.setArg(1, scalar_size, &scalar_arg_so));
    OCL_CHECK(err, err = kernel_monte_sim.setArg(2, scalar_size, &scalar_arg_rate));
    OCL_CHECK(err, err = kernel_monte_sim.setArg(3, scalar_size, &scalar_arg_sigma));

    OCL_CHECK(err, err = kernel_monte_sim.setArg(0, buffer_in1));
    // OCL_CHECK(err, err = kernel_monte_sim.setArg(1, buffer_in2));
    OCL_CHECK(err, err = kernel_monte_sim.setArg(1, buffer_output));
    OCL_CHECK(err, err = kernel_monte_sim.setArg(2, size));

    // Copy input data to device global memory
    // OCL_CHECK(err, err = q.enqueueMigrateMemObjects({buffer_in1, buffer_in2}, 0));
    OCL_CHECK(err, err = q.enqueueMigrateMemObjects({buffer_in1}, 0));
    OCL_CHECK(err, err = q.enqueueTask(kernel_monte_sim));
    OCL_CHECK(err, err = q.enqueueMigrateMemObjects({buffer_output},
                                                    CL_MIGRATE_MEM_OBJECT_HOST));
    q.finish();
    
    //OpenCL Host Code Area End

    //Compare to sim
    bool match = true;
    for (int i = 0; i < DATA_SIZE; i++) {
        float conv_hw_res = static_cast<float>(source_hw_results[i]);
        if (conv_hw_res != source_sw_results[i]) {
            std::cout << "Error: Result mismatch" << std::endl;
            std::cout << "i = " << i << " val = " << source_in1[i] << " CPU result = " << source_sw_results[i]
                      << " Device result = " << source_hw_results[i]
                      << std::endl;
            match = false;
            // break;
        } else {
            std::cout << "SW result = " << source_sw_results[i] << " Device result = " << source_hw_results[i] << std::endl;
        }
    }

    std::cout << "TEST " << (match ? "PASSED" : "FAILED") << std::endl;
    return (match ? EXIT_SUCCESS : EXIT_FAILURE);



}