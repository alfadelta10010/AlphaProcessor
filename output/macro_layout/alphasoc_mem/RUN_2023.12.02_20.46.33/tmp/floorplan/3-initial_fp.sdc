###############################################################################
# Created by write_sdc
# Sat Dec  2 20:47:37 2023
###############################################################################
current_design alphasoc_mem
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name core_clk -period 1100.0000 [get_ports {clk}]
###############################################################################
# Environment
###############################################################################
###############################################################################
# Design Rules
###############################################################################
