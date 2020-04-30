-- ==============================================================
-- Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- ==============================================================
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity monte_sim_dev_log_67_17_s_log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V_rom is 
    generic(
             DWIDTH     : integer := 67; 
             AWIDTH     : integer := 6; 
             MEM_SIZE    : integer := 64
    ); 
    port (
          addr0      : in std_logic_vector(AWIDTH-1 downto 0); 
          ce0       : in std_logic; 
          q0         : out std_logic_vector(DWIDTH-1 downto 0);
          clk       : in std_logic
    ); 
end entity; 


architecture rtl of monte_sim_dev_log_67_17_s_log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V_rom is 

signal addr0_tmp : std_logic_vector(AWIDTH-1 downto 0); 
type mem_array is array (0 to MEM_SIZE-1) of std_logic_vector (DWIDTH-1 downto 0); 
signal mem : mem_array := (
    0 to 2=> "1111111101111100000111101111110100011001001111101110011101010000110", 
    3 to 4=> "0000011110011100110011011100001000001100111000010000100110001000110", 
    5 to 6=> "0001000000000001101101111011001010110111011110001110110111011001011", 
    7 to 9=> "0001100010101111011111010101101001110010100010000110111111111110111", 
    10 to 11=> "0010000110101011001111000000000101101001000001111101111100001101001", 
    12 to 14=> "0010101011111010100111111101001111000001101110100100101101000111110", 
    15 to 17=> "0011010010100011111110010111011000101110111100101010111000101111001", 
    18 to 21=> "0011111010101110010101111101011010000000101001011101101001001100000", 
    22 to 25=> "0100100100100001101001110100000111101100101011010011000100110001101", 
    26 to 29=> "0101010000000110110101110001100111111011110011100100011010001001000", 
    30 to 31=> "0101111101101000000001111110110001111001100100110101011100001000011", 
    32 to 33=> "1011001111011000100101000001000110010100110010100010010011100000000", 
    34 to 35=> "1011100111011110101011000100111001101010101001101010111101000010010", 
    36 to 38=> "1100000000001001111011100010001001011100110000101001001000110110001", 
    39 to 41=> "1100011001011100001011110110110111100100000010101010001111111000100", 
    42 to 43=> "1100110011010111011010011100001100110000100100010111111001100100010", 
    44 to 46=> "1101001101111101101111100001101111001010000101110011111110111111111", 
    47 to 49=> "1101101001010001011110010000110011011001010101001010000010111000110", 
    50 to 53=> "1110000101010101000101111000111011101110010011000000000101100110111", 
    54 to 56=> "1110100010001011010011000111001000110011110100111001101110110100111", 
    57 to 60=> "1110111111110111000001101001110100010000100011011001010000100000000", 
    61 to 63=> "1111011110011011011110000011100101111011001100100010011100111101100" );


begin 


memory_access_guard_0: process (addr0) 
begin
      addr0_tmp <= addr0;
--synthesis translate_off
      if (CONV_INTEGER(addr0) > mem_size-1) then
           addr0_tmp <= (others => '0');
      else 
           addr0_tmp <= addr0;
      end if;
--synthesis translate_on
end process;

p_rom_access: process (clk)  
begin 
    if (clk'event and clk = '1') then
        if (ce0 = '1') then 
            q0 <= mem(CONV_INTEGER(addr0_tmp)); 
        end if;
    end if;
end process;

end rtl;

Library IEEE;
use IEEE.std_logic_1164.all;

entity monte_sim_dev_log_67_17_s_log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V is
    generic (
        DataWidth : INTEGER := 67;
        AddressRange : INTEGER := 64;
        AddressWidth : INTEGER := 6);
    port (
        reset : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        address0 : IN STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
        ce0 : IN STD_LOGIC;
        q0 : OUT STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0));
end entity;

architecture arch of monte_sim_dev_log_67_17_s_log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V is
    component monte_sim_dev_log_67_17_s_log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V_rom is
        port (
            clk : IN STD_LOGIC;
            addr0 : IN STD_LOGIC_VECTOR;
            ce0 : IN STD_LOGIC;
            q0 : OUT STD_LOGIC_VECTOR);
    end component;



begin
    monte_sim_dev_log_67_17_s_log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V_rom_U :  component monte_sim_dev_log_67_17_s_log_apfixed_reduce_log0_lut_table_ap_fixed_0_5_64_array_V_rom
    port map (
        clk => clk,
        addr0 => address0,
        ce0 => ce0,
        q0 => q0);

end architecture;


