# Define the clock signal (Essential for sequential logic!)
# "clk" must match the input port name in your Verilog code.
# -period 10.000 means 10ns cycle time (100 MHz).
create_clock -period 10.000 -name sys_clk [get_ports clk]

# Optional: Map the clock to a specific pin if you are putting this on a real board
# set_property PACKAGE_PIN E3 [get_ports clk]
# set_property IOSTANDARD LVCMOS33 [get_ports clk]