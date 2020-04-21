// Implement a Exponentiation Function


#include "xcl2.hpp"
#include <algorithm>
#include <cstdio>
#include <random>
#include <vector>
#include <math.h>

#define DATA_SIZE 4096

// pass a vector of numbers, return the exp(x) of those numbers
// or some manipulation of those numbers

int main(int argc, char **argv) {
    if (argc != 2) {
        std::cout << "Usage: " << argv[0] << " <XCLBIN File" << std::endl;
        return EXIT_FAILURE;
    }

    std::string binaryFile = argv[1];
    size_t vector_size_bytes = sizeof(int) * DATA_SIZE;
    cl_int err;
    cl::Context context;
    cl::Kernel kernel_monte_sim;
    cl::CommandQueue q;

    std::vector<int, aligned_allocator<int>> source_in1(DATA_SIZE);
    // std::vector<int, aligned_allocator<int>> source_in2(DATA_SIZE);   -- Only one source input
    std::vector<int, aligned_allocator<int>> source_hw_results(DATA_SIZE);
    std::vector<int, aligned_allocator<int>> source_sw_results(DATA_SIZE);

    // Create the test data
    std::generate(source_in1.begin(), source_in1.end(), std::rand);
    // std::generate(source_in2.begin(), source_in2.end(), std::rand);
    int x;
    for (int i = 0; i < DATA_SIZE; i++) {
        // source_sw_results[i] = source_in1[i] + source_in2[i];
        x = source_in1[i];
        source_sw_results[i] = exp (x);
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

    int size = DATA_SIZE;
    OCL_CHECK(err, err = kernel_monte_sim.setArg(0, buffer_in1));
    // OCL_CHECK(err, err = kernel_monte_sim.setArg(1, buffer_in2));
    OCL_CHECK(err, err = kernel_monte_sim.setArg(2, buffer_output));
    OCL_CHECK(err, err = kernel_monte_sim.setArg(3, size));

    // Copy input data to device global memory
    OCL_CHECK(err, err = q.enqueueMigrateMemObjects({buffer_in1, buffer_in2}, 0));
    OCL_CHECK(err, err = q.enqueueTask(kernel_monte_sim));
    OCL_CHECK(err, err = q.enqueueMigrateMemObjects({buffer_output},
                                                    CL_MIGRATE_MEM_OBJECT_HOST));
    q.finish();
    
    //OpenCL Host Code Area End

    //Compare to sim
    bool match = true;
    for (int i = 0; i < DATA_SIZE; i++) {
        if (source_hw_results[i] != source_sw_results[i]) {
            std::cout << "Error: Result mismatch" << std::endl;
            std::cout << "i = " << i << " CPU result = " << source_sw_results[i]
                      << " Device result = " << source_hw_results[i]
                      << std::endl;
            match = false;
            break;
        }
    }

    std::cout << "TEST " << (match ? "PASSED" : "FAILED") << std::endl;
    return (match ? EXIT_SUCCESS : EXIT_FAILURE);



}