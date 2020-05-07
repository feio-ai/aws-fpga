// Return the exponential of input vector

#include <stdio.h>
#include <string.h>
#include "hls_math.h"
#include "ap_fixed.h"

#define BUFFER_SIZE 1000
#define DATA_SIZE 100000

typedef ap_fixed<32,16> input_type;

typedef ap_fixed<16,7> fix_type;
typedef ap_fixed<8,3> scalar_type;

const unsigned int c_len = DATA_SIZE / BUFFER_SIZE;
const unsigned int c_size = BUFFER_SIZE;

extern "C" {

void monte_sim_dev(
                input_type *in1,
                input_type *in2,
                // fix_type *in1,
                // fix_type *in2,
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


    input_type v1_buffer[BUFFER_SIZE];
    input_type v2_buffer[BUFFER_SIZE];

    // fix_type v1_buffer[BUFFER_SIZE];
    // fix_type v2_buffer[BUFFER_SIZE];
    fix_type vout_buffer[BUFFER_SIZE];

    #pragma HLS ARRAY_PARTITION variable = v1_buffer block factor = 10

    for (int z = 0; z < 4; z++) {
        // #pragma HLS LOOP_TRIPCOUNT min=c_size max=c_size
        // #pragma HLS PIPELINE II=1
        v2_buffer[z] = in2[z];
    }

    input_type t = v2_buffer[0];
    input_type so = v2_buffer[1];
    input_type r = v2_buffer[2];
    input_type sig = v2_buffer[3];
    
/*
    fix_type t = v2_buffer[0];
    fix_type so = v2_buffer[1];
    fix_type r = v2_buffer[2];
    fix_type sig = v2_buffer[3];
*/      


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

        input_type duo = 2;
        input_type hls_p = hls::pow(sig, 2);
        input_type hls_sq = hls::sqrt(t);
        fix_type cons1 = r - (hls_p / 2) * t;
        fix_type cons2 = sig * hls_sq;


/*
        fix_type duo = 2;
        fix_type hls_p = hls::pow(sig, 2);
        fix_type hls_sq = hls::sqrt(t);
        fix_type cons1 = r - (hls_p / 2) * t;
        fix_type cons2 = sig * hls_sq;
*/

    monte_sim_dev:
        for (int j = 0; j < chunk_size; j++) {
            #pragma HLS LOOP_TRIPCOUNT min=c_size max=c_size
            #pragma HLS PIPELINE II=1

            input_type x = v1_buffer[j];
            fix_type hls_exp_c = hls::exp( cons1 + ( x * cons2) );
            fix_type s = so * hls_exp_c;
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

