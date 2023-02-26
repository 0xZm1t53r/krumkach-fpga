# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Glitching_Param [ipgui::add_page $IPINST -name "Glitching Param"]
  ipgui::add_param $IPINST -name "DELAY_1ST_DEFAULT" -parent ${Glitching_Param}
  ipgui::add_param $IPINST -name "TRIGGER_MIN_CNT" -parent ${Glitching_Param}
  ipgui::add_param $IPINST -name "DELAY_2ND_DEFAULT" -parent ${Glitching_Param}
  ipgui::add_param $IPINST -name "PULSE_WIDTH_DEFAULT" -parent ${Glitching_Param}
  ipgui::add_param $IPINST -name "TARGET_NRST_WIDTH_DEFAULT" -parent ${Glitching_Param}

  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {Base}]
  ipgui::add_param $IPINST -name "C_S_AXI_BASEADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_HIGHADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_ADDR_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.DELAY_1ST_DEFAULT { PARAM_VALUE.DELAY_1ST_DEFAULT } {
	# Procedure called to update DELAY_1ST_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DELAY_1ST_DEFAULT { PARAM_VALUE.DELAY_1ST_DEFAULT } {
	# Procedure called to validate DELAY_1ST_DEFAULT
	return true
}

proc update_PARAM_VALUE.DELAY_2ND_DEFAULT { PARAM_VALUE.DELAY_2ND_DEFAULT } {
	# Procedure called to update DELAY_2ND_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DELAY_2ND_DEFAULT { PARAM_VALUE.DELAY_2ND_DEFAULT } {
	# Procedure called to validate DELAY_2ND_DEFAULT
	return true
}

proc update_PARAM_VALUE.PULSE_WIDTH_DEFAULT { PARAM_VALUE.PULSE_WIDTH_DEFAULT } {
	# Procedure called to update PULSE_WIDTH_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PULSE_WIDTH_DEFAULT { PARAM_VALUE.PULSE_WIDTH_DEFAULT } {
	# Procedure called to validate PULSE_WIDTH_DEFAULT
	return true
}

proc update_PARAM_VALUE.TARGET_NRST_WIDTH_DEFAULT { PARAM_VALUE.TARGET_NRST_WIDTH_DEFAULT } {
	# Procedure called to update TARGET_NRST_WIDTH_DEFAULT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TARGET_NRST_WIDTH_DEFAULT { PARAM_VALUE.TARGET_NRST_WIDTH_DEFAULT } {
	# Procedure called to validate TARGET_NRST_WIDTH_DEFAULT
	return true
}

proc update_PARAM_VALUE.TRIGGER_MIN_CNT { PARAM_VALUE.TRIGGER_MIN_CNT } {
	# Procedure called to update TRIGGER_MIN_CNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TRIGGER_MIN_CNT { PARAM_VALUE.TRIGGER_MIN_CNT } {
	# Procedure called to validate TRIGGER_MIN_CNT
	return true
}

proc update_PARAM_VALUE.C_S_AXI_BASEADDR { PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to update C_S_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_BASEADDR { PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to validate C_S_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_HIGHADDR { PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to update C_S_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_HIGHADDR { PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to validate C_S_AXI_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.TRIGGER_MIN_CNT { MODELPARAM_VALUE.TRIGGER_MIN_CNT PARAM_VALUE.TRIGGER_MIN_CNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TRIGGER_MIN_CNT}] ${MODELPARAM_VALUE.TRIGGER_MIN_CNT}
}

proc update_MODELPARAM_VALUE.DELAY_1ST_DEFAULT { MODELPARAM_VALUE.DELAY_1ST_DEFAULT PARAM_VALUE.DELAY_1ST_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DELAY_1ST_DEFAULT}] ${MODELPARAM_VALUE.DELAY_1ST_DEFAULT}
}

proc update_MODELPARAM_VALUE.DELAY_2ND_DEFAULT { MODELPARAM_VALUE.DELAY_2ND_DEFAULT PARAM_VALUE.DELAY_2ND_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DELAY_2ND_DEFAULT}] ${MODELPARAM_VALUE.DELAY_2ND_DEFAULT}
}

proc update_MODELPARAM_VALUE.PULSE_WIDTH_DEFAULT { MODELPARAM_VALUE.PULSE_WIDTH_DEFAULT PARAM_VALUE.PULSE_WIDTH_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PULSE_WIDTH_DEFAULT}] ${MODELPARAM_VALUE.PULSE_WIDTH_DEFAULT}
}

proc update_MODELPARAM_VALUE.TARGET_NRST_WIDTH_DEFAULT { MODELPARAM_VALUE.TARGET_NRST_WIDTH_DEFAULT PARAM_VALUE.TARGET_NRST_WIDTH_DEFAULT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TARGET_NRST_WIDTH_DEFAULT}] ${MODELPARAM_VALUE.TARGET_NRST_WIDTH_DEFAULT}
}

proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

