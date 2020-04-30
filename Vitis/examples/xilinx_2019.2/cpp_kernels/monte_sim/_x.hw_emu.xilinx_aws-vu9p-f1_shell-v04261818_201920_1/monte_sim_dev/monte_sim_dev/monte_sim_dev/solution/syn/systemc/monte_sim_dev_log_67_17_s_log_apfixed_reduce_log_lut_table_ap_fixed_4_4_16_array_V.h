// ==============================================================
// Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef __monte_sim_dev_log_67_17_s_log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V_H__
#define __monte_sim_dev_log_67_17_s_log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V_H__


#include <systemc>
using namespace sc_core;
using namespace sc_dt;




#include <iostream>
#include <fstream>

struct monte_sim_dev_log_67_17_s_log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V_ram : public sc_core::sc_module {

  static const unsigned DataWidth = 63;
  static const unsigned AddressRange = 16;
  static const unsigned AddressWidth = 4;

//latency = 1
//input_reg = 1
//output_reg = 0
sc_core::sc_in <sc_lv<AddressWidth> > address0;
sc_core::sc_in <sc_logic> ce0;
sc_core::sc_out <sc_lv<DataWidth> > q0;
sc_core::sc_in<sc_logic> reset;
sc_core::sc_in<bool> clk;


sc_lv<DataWidth> ram[AddressRange];


   SC_CTOR(monte_sim_dev_log_67_17_s_log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V_ram) {
        ram[0] = "0b000000000000000000000000000000000000000000000000000000000000000";
        ram[1] = "0b000100000000000000000001010101010101010110001000100010001001000";
        ram[2] = "0b001000000001000000010010101111101100001100101111100011011010110";
        ram[3] = "0b001100000011000001010100100111010011101100101010000110001011101";
        ram[4] = "0b010000000110000011100111101100111111100110000010010001100101111";
        ram[5] = "0b010100001010000111101101001010100001001101111100110110001011011";
        ram[6] = "0b011000001111001110000110100011000000111011110011100100011000010";
        ram[7] = "0b011100010101010111010101110011011000000111010101001101100001100";
        ram[8] = "0b011110011000110101001100010110101011110101101111111111111101000";
        ram[9] = "0b100010100000100011101100111110011010010011100110010111010001111";
        ram[10] = "0b100110101001010110011010001001101101001110000110001011100111010";
        ram[11] = "0b101010110011001101110111010010111101100111100011100001100000001";
        ram[12] = "0b101110111110001010101000010000010001000010011110111110111010011";
        ram[13] = "0b110011001010001101010001010011110110100001011110010100110100011";
        ram[14] = "0b110111010111010110010111001100100100001101001100000110100110111";
        ram[15] = "0b111011100101100110011111000110010101100001011010100101011101010";


SC_METHOD(prc_write_0);
  sensitive<<clk.pos();
   }


void prc_write_0()
{
    if (ce0.read() == sc_dt::Log_1) 
    {
            if(address0.read().is_01() && address0.read().to_uint()<AddressRange)
              q0 = ram[address0.read().to_uint()];
            else
              q0 = sc_lv<DataWidth>();
    }
}


}; //endmodule


SC_MODULE(monte_sim_dev_log_67_17_s_log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V) {


static const unsigned DataWidth = 63;
static const unsigned AddressRange = 16;
static const unsigned AddressWidth = 4;

sc_core::sc_in <sc_lv<AddressWidth> > address0;
sc_core::sc_in<sc_logic> ce0;
sc_core::sc_out <sc_lv<DataWidth> > q0;
sc_core::sc_in<sc_logic> reset;
sc_core::sc_in<bool> clk;


monte_sim_dev_log_67_17_s_log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V_ram* meminst;


SC_CTOR(monte_sim_dev_log_67_17_s_log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V) {
meminst = new monte_sim_dev_log_67_17_s_log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V_ram("monte_sim_dev_log_67_17_s_log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V_ram");
meminst->address0(address0);
meminst->ce0(ce0);
meminst->q0(q0);

meminst->reset(reset);
meminst->clk(clk);
}
~monte_sim_dev_log_67_17_s_log_apfixed_reduce_log_lut_table_ap_fixed_4_4_16_array_V() {
    delete meminst;
}


};//endmodule
#endif
