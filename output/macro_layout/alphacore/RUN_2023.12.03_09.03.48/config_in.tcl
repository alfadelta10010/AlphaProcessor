set ::env(DESIGN_NAME) "alphacore"
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]
#set ::env(EXTRA_LIBS) [glob $::env(DESIGN_DIR)/src/*.lib]
set ::env(BASE_SDC_FILE) [glob $::env(DESIGN_DIR)/src/*.sdc]
set ::env(FP_PIN_ORDER_CFG) [glob $::env(DESIGN_DIR)/pin_order.cfg]

set ::env(CLOCK_PERIOD) "1100.00"
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)

set ::env(DESIGN_IS_CORE) {0}
set ::env(RUN_HEURISTIC_DIODE_INSERTION) {1}
