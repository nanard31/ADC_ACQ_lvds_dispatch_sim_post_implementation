//------------------------------------------------------------------------
// ramtest.v
//
// This sample uses the Xilinx MIG DDR3 controller and HDL to move data
// from the PC to the DDR3 and vice-versa. Based on MIG generated example_top.v.
//
// Host Interface registers:
// WireIn 0x00
//     0 - DDR3 read enable (0=disabled, 1=enabled)
//     1 - DDR3 write enable (0=disabled, 1=enabled)
//     2 - Reset
//
// PipeIn 0x80 - DDR3 write port (U11, DDR2)
// PipeOut 0xA0 - DDR3 read port (U11, DDR2)
//
// This sample is included for reference only.  No guarantees, either
// expressed or implied, are to be drawn.
//------------------------------------------------------------------------
// tabstop 3
// Copyright (c) 2005-2016 Opal Kelly Incorporated
// $Rev$ $Date$
//------------------------------------------------------------------------
`timescale 1ns/1ps

module ramtest (


	input  wire         sys_clk_p,
	input  wire         sys_clk_n,
	

	
	output wire [4 :0]  o_ADC_CNV_n,
    output wire [4 :0]  o_ADC_SCK_n,
    output wire [4 :0]  o_ADC_SCK_p,
	
    input  wire [9 :0]  i_ADC_SDO_p,
    input  wire [9 :0]  i_ADC_SDO_n,
	
	input  wire        	sys_rst              // for simulation
	
	);

	wire [4:0] ADC_SCK;    //: in std_logic_vector(0 to 3);             -- SPI Serial Clock
        
    wire [9:0] ADC_SDO ;  // : in std_logic_vector(0 to 3);             -- SPI Convert Input, negative polarity
	
	wire [159: 0] o_dout;      //160 bits=16x10
	
	wire clk;
	
	wire [9:0] o_rdy;          //10 bits
	
	wire [169: 0] probe0;
 
ila_0 u_ila_0(
	  .clk	(clk),
	  .probe0 (probe0)
	  );

assign probe0 = {o_dout,o_rdy};

clk_wiz_0 clock_buf(
  // Clock in ports
 .clk_in1_p	(sys_clk_p),
 .clk_in1_n	(sys_clk_n),
  // Clock out ports
  //.clk_400Mhz(sys_clk_i),
  .clk	(clk)
  //.clk_200MHz_DDR3(sys_clk_i),
  //.clk_100MHz(Clk_100MHz)
  // Status and control signals
  //.reset(ep00wire[2]),
  //.locked(locked)
 );


Test_Template Test_Template_instance (
    .rst(sys_rst),	// fix for simulation
    .clk(clk),
    .i_start(1'b1),
    .o_finished(),
    .i_debug_en(1'b0),
    .o_start_led(),
    //.i_samples_count(16'hffffffff),
    .o_data(o_dout),
    .o_rdy(o_rdy),
	
	.o_ADC_SCK(ADC_SCK),     	             // SPI Serial Clock
    .o_ADC_CNV_n(o_ADC_CNV_n),   	         // SPI Convert Input, negative polarity
    .i_ADC_SDO(ADC_SDO)

	//.init_calib_complete(init_calib_complete)    //place for simulation	
	
/*     .o_adc_sck_p(o_adc_sck_p),
    .o_adc_sck_n(o_adc_sck_n),
    .o_adc_cnv_n(o_adc_cnv_n),
    .i_adc_sdo_p(i_adc_sdo_p),
    .i_adc_sdo_n(i_adc_sdo_n) */
);




genvar i;
generate
    for (i=0; i<=4; i=i+1) begin: OBUFDS
    OBUFDS whatever_OBUFDS (
        .I(ADC_SCK[i]),
		.O(o_ADC_SCK_p[i]),
        .OB(o_ADC_SCK_n[i])

    );
end 
endgenerate
 
/* assign o_ADC_Sck_p = o_ADC_Sck_p_wire;
assign o_ADC_Sck_n = o_ADC_Sck_n_wire;  */
 
genvar v;
generate
    for (v=0; v<=9; v=v+1) begin: IBUFDS
    IBUFDS whatever_IBUFDS (
        .I(i_ADC_SDO_p[v]),
        .IB(i_ADC_SDO_n[v]),
        .O(ADC_SDO[v])

    );
end 
endgenerate	



/* assign o_ADC_CNV_n[0] = iADC_CNV_n[0];
assign o_ADC_CNV_n[1] = iADC_CNV_n[2];
assign o_ADC_CNV_n[2] = iADC_CNV_n[4];
assign o_ADC_CNV_n[3] = iADC_CNV_n[6]; */	
	
endmodule
