// Return the exponential of input vector

#include <stdio.h>
#include <string.h>
#include "hls_math.h"
#include "ap_fixed.h"

#define BUFFER_SIZE 1000
#define DATA_SIZE 100000


typedef ap_fixed<32,16> fix_type;
typedef ap_fixed<16,7> red_fix_type;
typedef ap_fixed<8,3> scalar_type;

const fix_type ov_2 = 0.5;
const fix_type ov_6 = 0.166667;
const fix_type ov_24 = 0.416667;
const fix_type ov_120 = 0.008333;
const fix_type ov_720 = 0.0013889;
// const fix_type ov_5040 = 0.000198413;

const unsigned int c_len = DATA_SIZE / BUFFER_SIZE;
const unsigned int c_size = BUFFER_SIZE;

extern "C" {

void monte_sim(
                fix_type *in1,
                fix_type *in2,
                fix_type *out_r,
                int size
) {

// Buffer inputs
#pragma HLS INTERFACE m_axi port=in1 offset=slave bundle=gmem
#pragma HLS INTERFACE m_axi port=in2 offset=slave bundle=gmem
#pragma HLS INTERFACE m_axi port=out_r offset=slave bundle=gmem
#pragma HLS INTERFACE s_axilite port = in1 bundle = control
#pragma HLS INTERFACE s_axilite port = in2 bundle = control
#pragma HLS INTERFACE s_axilite port = out_r bundle = control
#pragma HLS INTERFACE s_axilite port = size bundle = control
#pragma HLS INTERFACE s_axilite port = return bundle = control

    fix_type v1_buffer[BUFFER_SIZE];
    fix_type v2_buffer[BUFFER_SIZE];
    fix_type vout_buffer[BUFFER_SIZE];

    // Read Constants loop
    for (int z = 0; z < 4; z++) {
        // #pragma HLS LOOP_TRIPCOUNT min=c_size max=c_size
        // #pragma HLS PIPELINE II=1
        v2_buffer[z] = in2[z];
    }

    fix_type t = v2_buffer[0];
    fix_type so = v2_buffer[1];
    fix_type r = v2_buffer[2];
    fix_type sig = v2_buffer[3];

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
                // PIPELINE pragma reduces the initiation interval for loop by allowing the
                // concurrent executions of operations

        fix_type duo = 2;
        fix_type trio = 3;
        fix_type hls_p = hls::pow(sig, duo);
        fix_type hls_sq = hls::sqrt(t);
    monte_sim:
        for (int j = 0; j < chunk_size; j++) {
            #pragma HLS LOOP_TRIPCOUNT min=c_size max=c_size
            #pragma HLS PIPELINE II=1

            fix_type x = v1_buffer[j];
                    
            fix_type xo = (r - ( hls_p / duo ) * t) + ( x * sig * hls_sq);
            fix_type x2 = hls::pow(xo, duo);
            fix_type x3 = hls::pow(xo, trio);
            fix_type x4 = hls::pow(x2, duo);
            fix_type x5 = hls::pow(x2, trio);
            fix_type x6 = hls::pow(x4, duo);
                    

            fix_type exp_result = 1 + xo + (x2 * ov_2) + (x3 * ov_6) + (x4 * ov_24) + (x5 * ov_120) + (x6 * ov_720);
            fix_type s = so * exp_result;
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


