`timescale 1ns / 1ps

`include "aes_interface.sv"
`include "aes_test.sv"

module tb_top;

    // Physical wires for clock and reset
    logic clk;
    logic reset;

    // 1. Clock Generation (10ns period -> 100MHz)
    always #5 clk = ~clk;

    // 2. Reset Generation
    initial begin
        clk = 0;
        reset = 1;       // Activate reset (Active High)
        #100 reset = 0;  // Deactivate reset after 100ns
    end

    // 3. Instantiate the Interface
    aes_interface i_intf(clk, reset);

    // 4. Instantiate the Test Program, passing the interface
    test t1(i_intf);

    // 5. Instantiate the Unit Under Test (The infected AES core)
    // We connect the core directly to the signals inside the interface!
    aes_128 DUT (
        .clk(i_intf.clk),
        .state(i_intf.state),
        .key(i_intf.key),
        .out(i_intf.out)
    );

endmodule
