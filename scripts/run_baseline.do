if {[file exists work]} {
	vdel -lib work -all
}

vlib work
vmap work work

vlog -incr ../rtl/*.v
vlog -incr ../tb/test_aes_128.v

vsim -novopt work.test_aes_128

run 0

vcd file ../activity_logs/infected.vcd

vcd add -r *

run -all

vcd flush 
quit
