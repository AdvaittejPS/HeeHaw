# =========================================================================
# Project Hee-Haw: Automated Trojan Regression Suite
# =========================================================================

# Define a list of your RTL files and their desired output VCD names
set trojan_suite {
    {"../rtl/aes_128.sv"                  "clean_baseline.vcd"}
    {"../rtl/aes_128_direct_key_leak.sv"  "infected_01_direct_key.vcd"}
    {"../rtl/aes_128_lsb.sv"              "infected_02_lsb_leak.vcd"}
    {"../rtl/aes_timebomb_data.sv"        "infected_03_timebomb_data.vcd"}
    {"../rtl/aes_timebomb_keyleak.sv"     "infected_04_timebomb_key.vcd"}
    {"../rtl/aes_fsm.sv"                  "infected_05_fsm.vcd"}
    {"../rtl/aes_128_comb_data_leak.sv"   "infected_06_comb_leak.vcd"}
}

# Loop through each pair in the suite
foreach trojan_pair $trojan_suite {
    
    # Extract the file name and vcd name from the list
    set rtl_file [lindex $trojan_pair 0]
    set vcd_name [lindex $trojan_pair 1]

    puts "================================================="
    puts "⚙️ STARTING SIMULATION FOR: $rtl_file"
    puts "📁 OUTPUT WILL BE SAVED TO: $vcd_name"
    puts "================================================="

    # 1. Clean the workspace for a fresh simulation
    if {[file exists work]} { vdel -lib work -all }
    vlib work

    # 2. Compile the common AES math files first
    vlog -incr ../rtl/table.sv
    vlog -incr ../rtl/round.sv

    # 3. Compile the specific Trojan file for this loop
    vlog -incr $rtl_file

    # 4. Compile the Testbench
    vlog -incr ../tb/tb_top.sv

    # 5. Load the simulation
    vsim -c -novopt work.tb_top

    # 6. Setup VCD tracing
    run 0
    vcd file ../activity_logs/$vcd_name
    vcd add -r *

    # 7. Run the full stress test
    run -all

    # 8. Flush the VCD buffer and close *only* the current simulation
    vcd flush
    quit -sim
}

puts "================================================="
puts "✅ ALL SIMULATIONS COMPLETE. VCDs GENERATED."
puts "================================================="
quit
