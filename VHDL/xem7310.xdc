############################################################################
# XEM7310 - Xilinx constraints file
#
# Pin mappings for the XEM7310.  Use this as a template and comment out
# the pins that are not used in your design.  (By default, map will fail
# if this file contains constraints for signals not in your design).
#
# Copyright (c) 2004-2016 Opal Kelly Incorporated
############################################################################

set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS True [current_design]

set_property PACKAGE_PIN Y9  [get_ports  {sys_rst}]
set_property IOSTANDARD LVCMOS25 [get_ports {sys_rst}]

############################################################################
## ADCs
############################################################################
##################################################DU1_CONV_B
set_property PACKAGE_PIN V8  [get_ports  {o_ADC_CNV_n[0]}]	
###################################################DU1_SCK+
set_property PACKAGE_PIN Y8  [get_ports  {o_ADC_SCK_p[0]}]	
###################################################DU1_SCK-
set_property PACKAGE_PIN Y7  [get_ports {o_ADC_SCK_n[0]}]	
###################################################DU1_SI_FRONT_SDO+
set_property PACKAGE_PIN V7 [get_ports {i_ADC_SDO_p[0]}]
###################################################DU1_SI_FRONT_SDO-	
set_property PACKAGE_PIN W7 [get_ports {i_ADC_SDO_n[0]}]	
###################################################DU2_CONV_B	
set_property PACKAGE_PIN Y2  [get_ports {o_ADC_CNV_n[1]}]
###################################################DU2_SCK+	
set_property PACKAGE_PIN AA1 [get_ports {o_ADC_SCK_p[1]}]
###################################################DU2_SCK-				
set_property PACKAGE_PIN AB1 [get_ports {o_ADC_SCK_n[1]}]	
###################################################DU2_SI_FRONT_SDO+
set_property PACKAGE_PIN T1 [get_ports {i_ADC_SDO_p[1]}]	
###################################################DU2_SI_FRONT_SDO-
set_property PACKAGE_PIN U1 [get_ports {i_ADC_SDO_n[1]}]	
###################################################DU3_CONV_B
set_property PACKAGE_PIN W9 [get_ports {o_ADC_CNV_n[2]}]
###################################################DU3_SCK+	
set_property PACKAGE_PIN U6 [get_ports {o_ADC_SCK_p[2]}]
###################################################DU3_SCK-	
set_property PACKAGE_PIN V5 [get_ports {o_ADC_SCK_n[2]}]	
###################################################DU3_SI_FRONT_SDO+
set_property PACKAGE_PIN R6 [get_ports {i_ADC_SDO_p[2]}]	
###################################################DU3_SI_FRONT_SDO-
set_property PACKAGE_PIN T6 [get_ports {i_ADC_SDO_n[2]}]	
###################################################DU4_CONV_B
set_property PACKAGE_PIN U2 [get_ports {o_ADC_CNV_n[3]}]	
###################################################DU4_SCK+
set_property PACKAGE_PIN R3 [get_ports {o_ADC_SCK_p[3]}]	
###################################################DU4_SCK-
set_property PACKAGE_PIN R2 [get_ports {o_ADC_SCK_n[3]}]	
###################################################DU4_SI_FRONT_SDO+
set_property PACKAGE_PIN Y3 [get_ports {i_ADC_SDO_p[3]}]	
###################################################DU4_SI_FRONT_SDO-
set_property PACKAGE_PIN AA3 [get_ports {i_ADC_SDO_n[3]}]	
###################################################DU1_SI_BACK_SDO+
set_property PACKAGE_PIN W6 [get_ports {i_ADC_SDO_p[4]}]
###################################################DU1_SI_BACK_SDO-
set_property PACKAGE_PIN W5 [get_ports {i_ADC_SDO_n[4]}]
###################################################DU2_SI_BACK_SDO+
set_property PACKAGE_PIN V4 [get_ports {i_ADC_SDO_p[5]}]
###################################################DU2_SI_BACK_SDO-
set_property PACKAGE_PIN W4 [get_ports {i_ADC_SDO_n[5]}]
###################################################DU3_SI_BACK_SDO+
set_property PACKAGE_PIN T5 [get_ports {i_ADC_SDO_p[6]}]
###################################################DU3_SI_BACK_SDO-
set_property PACKAGE_PIN U5 [get_ports {i_ADC_SDO_n[6]}]
###################################################DU4_SI_BACK_SDO+
set_property PACKAGE_PIN AB7 [get_ports {i_ADC_SDO_p[7]}]
###################################################DU4_SI_BACK_SDO-
set_property PACKAGE_PIN AB6 [get_ports {i_ADC_SDO_n[7]}]

#####################################################################
#SPARE
###################################################################
set_property PACKAGE_PIN Y6   [get_ports {o_ADC_SCK_p[4]}]
set_property PACKAGE_PIN AA6  [get_ports {o_ADC_SCK_n[4]}]
set_property PACKAGE_PIN AA4  [get_ports {o_ADC_CNV_n[4]}]
###################################################
set_property PACKAGE_PIN AA8  [get_ports {i_ADC_SDO_p[8]}]
###################################################-
set_property PACKAGE_PIN AB8  [get_ports {i_ADC_SDO_n[8]}]
######################################################################
###################################################
set_property PACKAGE_PIN  U3  [get_ports {i_ADC_SDO_p[9]}]
###################################################-
set_property PACKAGE_PIN  V3   [get_ports {i_ADC_SDO_n[9]}]
######################################################################

#set_property PACKAGE_PIN Y16 [get_ports {o_ADC_SCK_p[3]}]
#set_property PACKAGE_PIN AA16 [get_ports {o_ADC_SCK_n[3]}]

#set_property PACKAGE_PIN W9 [get_ports {o_ADC_SCK_p[5]}]
#set_property PACKAGE_PIN Y9 [get_ports {o_ADC_SCK_n[5]}]

#set_property PACKAGE_PIN Y6 [get_ports {o_ADC_SCK_p[7]}]
#set_property PACKAGE_PIN AA6 [get_ports {o_ADC_SCK_n[7]}]

create_clock -period 10.000 -name o_ADC_SCK_p [get_ports {o_ADC_SCK_p[*]}]

set_property IOSTANDARD LVDS_25 [get_ports {o_ADC_SCK_p[*]}]
set_property IOSTANDARD LVDS_25 [get_ports {o_ADC_SCK_n[*]}]

set_property DIFF_TERM TRUE  [get_ports {i_ADC_SDO_p[*]}]

set_property IOSTANDARD LVDS_25 [get_ports {i_ADC_SDO_p[*]}]
set_property IOSTANDARD LVDS_25 [get_ports {i_ADC_SDO_n[*]}]

set_property IOSTANDARD LVCMOS25 [get_ports {o_ADC_CNV_n[*]}]







############################################################################
## System Clock
############################################################################
set_property IOSTANDARD LVDS_25 [get_ports sys_clk_p]

set_property IOSTANDARD LVDS_25 [get_ports sys_clk_n]
set_property PACKAGE_PIN W11 [get_ports sys_clk_p]
set_property PACKAGE_PIN W12 [get_ports sys_clk_n]
