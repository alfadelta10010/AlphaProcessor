set ::env(DESIGN_NAME) "alphasoc"
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/module/*.v]
set ::env(EXTRA_LIBS) [glob $::env(DESIGN_DIR)/src/*.lib]
set ::env(BASE_SDC_FILE) [glob $::env(DESIGN_DIR)/src/*.sdc]

set ::env(CLOCK_PERIOD) "1100.00"
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)
#set ::env(PL_TARGET_DENSITY) ""
set ::env(FP_CORE_UTIL) "80"
