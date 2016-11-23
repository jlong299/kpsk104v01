// (C) 2001-2015 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module  lpm_mult_25_18_lpm_mult_151_lnncfha  (
            clock,
            dataa,
            datab,
            result);

            input  clock;
            input [24:0] dataa;
            input [17:0] datab;
            output [42:0] result;

            wire [42:0] sub_wire0;
            wire [42:0] result = sub_wire0[42:0];    

            lpm_mult        lpm_mult_component (
                                        .clock (clock),
                                        .dataa (dataa),
                                        .datab (datab),
                                        .result (sub_wire0),
                                        .aclr (1'b0),
                                        .clken (1'b1),
                                        .sum (1'b0));
            defparam
                    lpm_mult_component.lpm_hint = "MAXIMIZE_SPEED=9",
                    lpm_mult_component.lpm_pipeline = 2,
                    lpm_mult_component.lpm_representation = "SIGNED",
                    lpm_mult_component.lpm_type = "LPM_MULT",
                    lpm_mult_component.lpm_widtha = 25,
                    lpm_mult_component.lpm_widthb = 18,
                    lpm_mult_component.lpm_widthp = 43;


endmodule


