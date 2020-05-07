// Implement a Exponentiation Function


#include "xcl2.hpp"
// #include "hls_math.h"
#include <algorithm>
#include <cstdio>
#include <random>
#include <vector>
#include <iostream>
#include <fstream>
#include <iterator>
#include <cmath>
#include "ap_fixed.h"

using std::mt19937;
using std::generate;
using std::uniform_real_distribution;
using std::vector;

#define DATA_SIZE 100000
#define CONST_SIZE 4


typedef ap_fixed<16,7> exp_fix_type;
typedef ap_fixed<32,16> red_fix_type;

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

exp_fix_type exp_rand_fix_gen() {
    float x = gen_random();
    float y = phi(x);

    // bitset<BIT_SET> bset1;
    // red_fix_type o = static_cast<red_fix_type>(y);
    exp_fix_type out = static_cast<exp_fix_type>(y);
    // fix_type out = o.range(24, 8);

    return out;
}


red_fix_type rand_fix_gen() {
    float x = gen_random();
    float y = phi(x);

    // bitset<BIT_SET> bset1;
    red_fix_type o = static_cast<red_fix_type>(y);
    // fix_type out = o.range(24, 8);

    return o;
}

void verify(
            vector<float, aligned_allocator<float>> &source_sw_results,
            vector<red_fix_type, aligned_allocator<red_fix_type>> &source_hw_results) {
    bool match = false;
    std::ofstream output_file("./monte_sim_sw_res.csv");
    std::ostream_iterator<float> output_iterator(output_file, "\n");
    std::copy(source_sw_results.begin(), source_sw_results.end(), output_iterator);

    std::ofstream f("./monte_sim_hw_res.csv");
    std::ostream_iterator<red_fix_type> output_iter(f, "\n");
    std::copy(source_hw_results.begin(), source_hw_results.end(), output_iter);

    std::cout << "TEST " << (match ? "PASSED" : "FAILED") << std::endl;
}

void exp_verify(
            vector<float, aligned_allocator<float>> &exp_source_sw_results,
            // vector<exp_fix_type, aligned_allocator<exp_fix_type>> &exp_source_hw_results
            vector<red_fix_type, aligned_allocator<red_fix_type>> &exp_source_hw_results) {
    bool match = true;
    for (int i = 0; i < 10; i++) {
        float conv_hw_res = static_cast<float>(exp_source_hw_results[i]);
        if (conv_hw_res != exp_source_sw_results[i]) {
            std::cout << "Error: Result mismatch" << std::endl;
            std::cout << " CPU result = " << exp_source_sw_results[i]
                      << " Device result = " << exp_source_hw_results[i]
                      << std::endl;
            match = false;
            // break;
        } else {
            std::cout << "SW result = " << exp_source_sw_results[i] << " Device result = " << exp_source_hw_results[i] << std::endl;
        }
    }
    std::cout << "TEST " << (match ? "PASSED" : "FAILED") << std::endl;
}

void acc_measure(vector<float, aligned_allocator<float>> &source_sw_results,
            vector<red_fix_type, aligned_allocator<red_fix_type>> &source_hw_results) {

    float sum_err = 0;
    float hw_sum_val = 0;
    float sw_sum_val = 0;
    
    for (int i = 0; i < DATA_SIZE; i++) {
        float conv_hw_res = static_cast<float>(source_hw_results[i]);
        // Count annomaly numbers
    
        hw_sum_val += conv_hw_res;
        sw_sum_val += source_sw_results[i];

        sum_err += abs(conv_hw_res - source_sw_results[i]) / source_sw_results[i];
     
    }
    float hw_avg_val = hw_sum_val / DATA_SIZE;
    float sw_avg_val = sw_sum_val / DATA_SIZE;
    float avg_err = sum_err / DATA_SIZE;
    std::cout << "Average Percent Error: " << avg_err
              << " Average Stock Value (HW): " << hw_avg_val
              << " Average Stock Value (SW): " << sw_avg_val 
              << std::endl;

}

void exp_acc_measure(vector<float, aligned_allocator<float>> &exp_source_sw_results,
            // vector<exp_fix_type, aligned_allocator<exp_fix_type>> &exp_source_hw_results
            vector<red_fix_type, aligned_allocator<red_fix_type>> &exp_source_hw_results) {
    
    float sum_err = 0;
    float sum_val = 0;
    float sw_sum_val = 0;

    for (int i = 0; i < DATA_SIZE; i++) {
        float conv_hw_res = static_cast<float>(exp_source_hw_results[i]);
        sum_val += conv_hw_res;
        sw_sum_val += exp_source_sw_results[i];
        sum_err += ((conv_hw_res - exp_source_sw_results[i]) / exp_source_sw_results[i]);   
    }
    float avg_val = sum_val / DATA_SIZE;
    float sw_avg_val = sw_sum_val / DATA_SIZE;
    float avg_err = sum_err / DATA_SIZE;
    std::cout << "Average Percent Error: " << avg_err
              << " Average Stock Value (HW): " << avg_val
              << " Average Stock Value (SW): " << sw_avg_val 
              << std::endl;

}

int main(int argc, char **argv) {
    if (argc != 2) {
        std::cout << "Usage: " << argv[0] << " <XCLBIN File" << std::endl;
        return EXIT_FAILURE;
    }

    std::string binaryFile = argv[1];
    size_t vector_size_bytes = sizeof(red_fix_type) * DATA_SIZE;
    size_t const_vector_size_bytes = sizeof(red_fix_type) * CONST_SIZE;
    size_t exp_vector_size_bytes = sizeof(exp_fix_type) * DATA_SIZE;
    size_t exp_const_vector_size_bytes = sizeof(exp_fix_type) * CONST_SIZE;


    cl_int err;
    cl::Context context;
    cl::Kernel kernel_monte_sim, kernel_monte_sim_dev;
    cl::CommandQueue q;
    cl::Program program;

    std::vector<red_fix_type, aligned_allocator<red_fix_type>> source_in1(DATA_SIZE);
    // std::vector<exp_fix_type, aligned_allocator<exp_fix_type>> exp_source_in1(DATA_SIZE);
    std::vector<red_fix_type, aligned_allocator<red_fix_type>> exp_source_in1(DATA_SIZE);
    std::vector<red_fix_type, aligned_allocator<red_fix_type>> source_const(CONST_SIZE);
    // std::vector<exp_fix_type, aligned_allocator<exp_fix_type>> exp_source_const(CONST_SIZE);
    std::vector<red_fix_type, aligned_allocator<red_fix_type>> exp_source_const(CONST_SIZE);
    std::vector<red_fix_type, aligned_allocator<red_fix_type>> source_hw_results(DATA_SIZE);

    std::vector<red_fix_type, aligned_allocator<red_fix_type>> exp_source_hw_results(DATA_SIZE);    
    // std::vector<exp_fix_type, aligned_allocator<exp_fix_type>> exp_source_hw_results(DATA_SIZE);
    std::vector<float, aligned_allocator<float>> source_sw_results(DATA_SIZE);
    std::vector<float, aligned_allocator<float>> exp_source_sw_results(DATA_SIZE);

    // Create the test data
    std::generate(source_in1.begin(), source_in1.end(), rand_fix_gen);
    std::generate(exp_source_in1.begin(), exp_source_in1.end(), rand_fix_gen);
    // std::generate(exp_source_in1.begin(), exp_source_in1.end(), exp_rand_fix_gen);
   

    float t = 0.5;
    float so = 50.0;
    float r = 0.05;
    float sig = 0.2;


    source_const.at(0) = (float)(0.5); // time
    source_const.at(1) = (float)(50.0); // so
    source_const.at(2) = (float)(0.05); // r
    source_const.at(3) = (float)(0.2); // sigma
    exp_source_const.at(0) = (float)(0.5); // time
    exp_source_const.at(1) = (float)(50.0); // so
    exp_source_const.at(2) = (float)(0.05); // r
    exp_source_const.at(3) = (float)(0.2); // sigma

/*
    exp_source_const.at(0) = (exp_fix_type)(0.5); // time
    exp_source_const.at(1) = (exp_fix_type)(50.0); // so
    exp_source_const.at(2) = (exp_fix_type)(0.05); // r
    exp_source_const.at(3) = (exp_fix_type)(0.2); // sigma
*/

    
    for (int i = 0; i < DATA_SIZE; i++) {
        
        red_fix_type x = source_in1[i];
        float x1 = static_cast<float>(x);
       
        // float z = exp(x1); 
        float z = so * exp( (r - ( pow(sig , 2) / 2 ) * t) + ( x1 * sig * sqrt(t)) );


        source_sw_results[i] = z;
        exp_source_sw_results[i] = z;
        exp_source_hw_results[i] = 0;
        source_hw_results[i] = 0;
    }
/*
    for (int i = 0; i < DATA_SIZE; i++) {
        
        exp_fix_type exp_x = exp_source_in1[i];
        float exp_x1 = static_cast<float>(exp_x);
       
        // float z = exp(x1); 
        float exp_z = so * exp( (r - ( pow(sig , 2) / 2 ) * t) + ( exp_x1 * sig * sqrt(t)) );

        exp_source_sw_results[i] = exp_z;
        exp_source_hw_results[i] = 0;
    }
*/
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
        program = cl::Program(context, {device}, bins, NULL, &err);
        if (err != CL_SUCCESS) {
            std::cout << "Faied to program device [" << i
                      << "] with xclbin file!\n";
        } else {
            std::cout << "Device[" << i << "]: program successful!\n";
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
  
    OCL_CHECK(err,
                cl::Buffer exp_buffer_in1(context,
                                    CL_MEM_USE_HOST_PTR | CL_MEM_READ_ONLY,
                                    // exp_vector_size_bytes,
                                    vector_size_bytes,
                                    exp_source_in1.data(),
                                    &err));

    OCL_CHECK(err,
                cl::Buffer buffer_in2(context,
                                    CL_MEM_USE_HOST_PTR | CL_MEM_READ_ONLY,
                                    const_vector_size_bytes,
                                    source_const.data(),
                                    &err));

    OCL_CHECK(err,
                cl::Buffer exp_buffer_in2(context,
                                    CL_MEM_USE_HOST_PTR | CL_MEM_READ_ONLY,
                                    // exp_const_vector_size_bytes,
                                    const_vector_size_bytes,
                                    exp_source_const.data(),
                                    &err));

    OCL_CHECK(err,
                cl::Buffer buffer_output(context,
                                        CL_MEM_USE_HOST_PTR | CL_MEM_WRITE_ONLY,
                                        vector_size_bytes,
                                        source_hw_results.data(),
                                        &err));

    OCL_CHECK(err,
                cl::Buffer exp_buffer_output(context,
                                        CL_MEM_USE_HOST_PTR | CL_MEM_WRITE_ONLY,
                                        vector_size_bytes,
                                        exp_source_hw_results.data(),
                                        &err));


    int size = DATA_SIZE;

    OCL_CHECK(err, kernel_monte_sim = cl::Kernel(program, "monte_sim", &err));    
    OCL_CHECK(err, err = kernel_monte_sim.setArg(0, buffer_in1));
    OCL_CHECK(err, err = kernel_monte_sim.setArg(1, buffer_in2));
    OCL_CHECK(err, err = kernel_monte_sim.setArg(2, buffer_output));
    OCL_CHECK(err, err = kernel_monte_sim.setArg(3, size));

    // Copy input data to device global memory
    OCL_CHECK(err, err = q.enqueueMigrateMemObjects({buffer_in1, buffer_in2}, 0));

    cl::Event event;
    uint64_t nstimestart, nstimeend;
    uint64_t nstimestart_exp, nstimeend_exp;

    OCL_CHECK(err, err = q.enqueueTask(kernel_monte_sim, NULL, &event));
    OCL_CHECK(err, err = q.enqueueMigrateMemObjects({buffer_output},
                                                    CL_MIGRATE_MEM_OBJECT_HOST));
    q.finish();

    OCL_CHECK(err,
              err = event.getProfilingInfo<uint64_t>(CL_PROFILING_COMMAND_START,
                                                     &nstimestart));
    OCL_CHECK(err,
              err = event.getProfilingInfo<uint64_t>(CL_PROFILING_COMMAND_END,
                                                     &nstimeend));
    auto monte_sim_time = nstimeend - nstimestart;

    verify(source_sw_results, source_hw_results);
    acc_measure(source_sw_results, source_hw_results);

    printf("--------------------------------------------------------\n"
           "Results from HLS exp function with reduced fixed point precision and range\n");

    OCL_CHECK(err, kernel_monte_sim_dev = cl::Kernel(program, "monte_sim_dev", &err));    
    OCL_CHECK(err, err = kernel_monte_sim_dev.setArg(0, exp_buffer_in1));
    OCL_CHECK(err, err = kernel_monte_sim_dev.setArg(1, exp_buffer_in2));
    OCL_CHECK(err, err = kernel_monte_sim_dev.setArg(2, exp_buffer_output));
    OCL_CHECK(err, err = kernel_monte_sim_dev.setArg(3, size));

    // Copy input data to device global memory
    OCL_CHECK(err, err = q.enqueueMigrateMemObjects({exp_buffer_in1, exp_buffer_in2}, 0));
    OCL_CHECK(err, err = q.enqueueTask(kernel_monte_sim_dev, NULL, &event));
    OCL_CHECK(err, err = q.enqueueMigrateMemObjects({exp_buffer_output},
                                                    CL_MIGRATE_MEM_OBJECT_HOST));
    q.finish();

    OCL_CHECK(err,
              err = event.getProfilingInfo<uint64_t>(CL_PROFILING_COMMAND_START,
                                                     &nstimestart_exp));
    OCL_CHECK(err,
              err = event.getProfilingInfo<uint64_t>(CL_PROFILING_COMMAND_END,
                                                     &nstimeend_exp));
    auto monte_sim_dev_time = nstimeend_exp - nstimestart_exp;

    exp_verify(exp_source_sw_results, exp_source_hw_results);
    exp_acc_measure(exp_source_sw_results, exp_source_hw_results);

    printf("|-------------------------+-------------------------|\n"
           "| Kernel                  |    Wall-Clock Time (ns) |\n"
           "|-------------------------+-------------------------|\n");

    printf("| %-23s | %23lu |\n", "monte_sim: ", monte_sim_time);
    printf("| %-23s | %23lu |\n", "monte_sim_exp: ", monte_sim_dev_time);
    printf("|-------------------------+-------------------------|\n");
    //OpenCL Host Code Area End

    
    return EXIT_SUCCESS;
    



}