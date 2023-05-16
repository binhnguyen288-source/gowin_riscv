//Copyright (C)2014-2023 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8.11 Education
//Created Time: 2023-05-11 22:56:40
create_clock -name osc -period 37.037 -waveform {0 18.518} [get_ports {osc}]


create_clock -period 20.000 -name eth_clk -add [get_ports {eth_clk}]
//set_clock_uncertainty 2.0 -from eth_clk


set_input_delay -clock eth_clk -max 6.000 [get_ports {eth_rx[0]}]
set_input_delay -clock eth_clk -min 0.400 [get_ports {eth_rx[0]}]
set_input_delay -clock eth_clk -max 6.000 [get_ports {eth_rx[1]}]
set_input_delay -clock eth_clk -min 0.400 [get_ports {eth_rx[1]}]
set_input_delay -clock eth_clk -max 6.000 [get_ports {eth_dv}]
set_input_delay -clock eth_clk -min 0.400 [get_ports {eth_dv}]

set_output_delay -clock eth_clk -max 8.000 [get_ports {eth_tx[0]}]
set_output_delay -clock eth_clk -min -3.000 [get_ports {eth_tx[0]}]
set_output_delay -clock eth_clk -max 8.000 [get_ports {eth_tx[1]}]
set_output_delay -clock eth_clk -min -3.000 [get_ports {eth_tx[1]}]
set_output_delay -clock eth_clk -max 8.000 [get_ports {eth_txen}]
set_output_delay -clock eth_clk -min -3.000 [get_ports {eth_txen}]