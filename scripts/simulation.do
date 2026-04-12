if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work
vlog -incr ../rtl/*.sv
vlog -incr ../tb/tb_top.sv

vsim -c -novopt work.tb_top

run 0

vcd file ../activity_logs/infected.vcd
vcd add -r *

run -all

vcd flush
quit
