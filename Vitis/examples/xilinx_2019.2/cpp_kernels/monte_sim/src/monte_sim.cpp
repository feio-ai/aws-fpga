// Return the exponential of input vector

#include <stdio.h>
#include <string.h>
#include "hls_math.h"
#include "ap_fixed.h"

#define NUM_STEPS 100
#define BUFFER_SIZE 1000
#define DATA_SIZE 100000

typedef ap_fixed<32,16> fix_type;

//TRIPCOUNT identifiers
// const unsigned int c_len = (DATA_SIZE * NUM_STEPS) / BUFFER_SIZE;
// const unsigned int c_size = BUFFER_SIZE;

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

    fix_type v1_buffer[BUFFER_SIZE][NUM_STEPS];
    fix_type v2_buffer[BUFFER_SIZE];
    fix_type vout_buffer[BUFFER_SIZE][NUM_STEPS];
    
// Read Constants loop
read_const:
    for (int z = 0; z < 4; z++) {
        v2_buffer[z] = in2[z];
    }

    fix_type t = v2_buffer[0];
    fix_type so = v2_buffer[1];
    fix_type r = v2_buffer[2];
    fix_type sig = v2_buffer[3];

    for (int i = 0; i < size * NUM_STEPS; i += BUFFER_SIZE) {
        int chunk_size = BUFFER_SIZE;

        if ((i + BUFFER_SIZE) > size)
            chunk_size = size - i;

    read1:
        for (int itr = 0, k = 0, j = 0; itr < chunk_size * NUM_STEPS; itr++, j++) {
            #pragma HLS PIPELINE II=1
            if (j == NUM_STEPS) {
                j = 0;
                k++;
            }
            v1_buffer[k][j] = in1[itr];
        }   

        fix_type hls_p = hls::pow(sig, 2);
        fix_type hls_sq = hls::sqrt(t);
        fix_type cons1 = r - (hls_p / 2) * t;
        fix_type cons2 = sig * hls_sq;
        
    monte_sim:
        for (int col = 0; col < BUFFER_SIZE; col++) {
            for (int row = 0; row < NUM_STEPS; row++) {
                #pragma HLS PIPELINE II=1
                fix_type result = (row == 0) ? so : vout_buffer[col][row - 1];

                fix_type x = v1_buffer[row][col];
                fix_type hls_exp_c = hls::exp( cons1 + ( x * cons2) );
                vout_buffer[col][row] = result * hls_exp_c;

            }
        }
            //burst write the result

    write:
        for (int itr = 0, x = 0, z = 0; itr < chunk_size * NUM_STEPS; itr++, z++) {
            #pragma HLS PIPELINE II=1
            if (z == NUM_STEPS) {
                z = 0;
                x++;
            }
            out_r[itr] = vout_buffer[x][z];
        }  

    }
        
}

}


