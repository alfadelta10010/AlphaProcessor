set ::env(DESIGN_NAME) "alphasoc"
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]
set ::env(EXTRA_LEFS) [glob $::env(DESIGN_DIR)/src/*.lef]
set ::env(EXTRA_LIBS) [glob $::env(DESIGN_DIR)/src/*.lib]
set ::env(EXTRA_GDS_FILES) [glob $::env(DESIGN_DIR)/src/*.gds]
set ::env(BASE_SDC_FILE) [glob $::env(DESIGN_DIR)/src/*.sdc]
set ::env(FP_PIN_ORDER_CFG) [glob $::env(DESIGN_DIR)/pin_order.cfg]
set ::env(MACRO_PLACEMENT_CFG) [glob $::env(DESIGN_DIR)/macro.cfg]
set ::env(MAGIC_EXT_USE_GDS) 1
set ::env(CLOCK_PERIOD) "1100.00"
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)
set ::env(DESIGN_IS_CORE) {1}
set ::env(RUN_HEURISTIC_DIODE_INSERTION) {1}
set ::env(DIE_AREA) "0 0 1 1"
set ::env(FP_SIZING) "absolute"
set ::env(FP_CORE_UTIL) 60
set ::env(PL_TARGET_DENSITY) 0.4
