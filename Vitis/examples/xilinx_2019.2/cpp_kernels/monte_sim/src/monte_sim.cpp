// Return the exponential of input vector

#include <stdio.h>
#include <string.h>
#include "hls_math.h"


#include "ap_fixed.h"

#define BUFFER_SIZE 1024
#define DATA_SIZE 4096

typedef ap_fixed<16,7, AP_RND, AP_SAT> fix_type;

const unsigned int c_len = DATA_SIZE / BUFFER_SIZE;
const unsigned int c_size = BUFFER_SIZE;

extern "C" {

    void monte_sim(fix_type *in1,
                // const unsigned int *in2,
                fix_type *out_r,
                int size
    ) {
        #pragma HLS INTERFACE m_axi port=in1 offset=slave bundle=gmem
        // #pragma HLS INTERFACE m_axi port=in2 offset=slave bundle=gmem
        #pragma HLS INTERFACE m_axi port=out_r offset=slave bundle=gmem
        #pragma HLS INTERFACE s_axilite port = in1 bundle = control
        // #pragma HLS INTERFACE s_axilite port = in2 bundle = control
        #pragma HLS INTERFACE s_axilite port = out_r bundle = control
        #pragma HLS INTERFACE s_axilite port = size bundle = control
        #pragma HLS INTERFACE s_axilite port = return bundle = control

            fix_type v1_buffer[BUFFER_SIZE];
            // unsigned int v2_buffer[BUFFER_SIZE];
            fix_type vout_buffer[BUFFER_SIZE];

            fix_type t = 0.5;
            fix_type so = 50.0;
            fix_type r = 0.05;
            fix_type sig = 0.2;

            for (int i = 0; i < size; i += BUFFER_SIZE) {
                #pragma HLS LOOP_TRIPCOUNT min=c_len max=c_len
                int chunk_size = BUFFER_SIZE;

                if ((i + BUFFER_SIZE) > size)
                    chunk_size = size - i;


            read1:
                for (int j = 0; j < chunk_size; j++) {
                    #pragma HLS LOOP_TRIPCOUNT min=c_size max=c_size
                    #pragma HLS PIPELINE II=1
                    v1_buffer[j] = in1[i + j];
                }
/*
            read2:
                for (int j = 0; j < chunk_size; j++) {
                    #pragma HLS LOOP_TRIPCOUNT min=c_size max=c_size
                    #pragma HLS PIPELINE II=1
                    v2_buffer[j] = in2[i + j];
                }
*/
                // PIPELINE pragma reduces the initiation interval for loop by allowing the
                // concurrent executions of operations
                ap_fixed<16,7> duo = 2;
            monte_sim:
                for (int j = 0; j < chunk_size; j++) {
                    #pragma HLS LOOP_TRIPCOUNT min=c_size max=c_size
                    #pragma HLS PIPELINE II=1
                    //perform vector addition
                    // vout_buffer[j] = v1_buffer[j] + v2_buffer[j];
                    
                    ap_fixed<16,7> x = v1_buffer[j];
                    ap_fixed<16,7> s = so * hls::exp( (r - ( hls::pow(sig , duo) / duo ) * t) + ( x * sig * hls::sqrt(t)) );
                    // ap_fixed<16,7> z = hls::exp(x);
                    vout_buffer[j] = s;
                }

            //burst write the result
            write:
                for (int j = 0; j < chunk_size; j++) {
                    #pragma HLS LOOP_TRIPCOUNT min=c_size max=c_size
                    #pragma HLS PIPELINE II=1
                    out_r[i + j] = vout_buffer[j];
                }
            }
        
    }


}

