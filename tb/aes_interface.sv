interface aes_interface(input logic clk, input logic reset);
    
    // The signals connecting to the AES core
    logic [127:0] state;
    logic [127:0] key;
    logic [127:0] out;

    // Clocking block for the Driver (synchronizes driving signals to the clock edge)
    clocking driver_cb @(posedge clk);
        output state;
        output key;
        input  out;
    endclocking

    // Clocking block for the Monitor (synchronizes reading signals)
    clocking monitor_cb @(posedge clk);
        input state;
        input key;
        input out;
    endclocking

endinterface
