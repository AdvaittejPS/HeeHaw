class aes_transaction;

    // REMOVED 'rand' keyword because we are reading these from the C-generated file
    bit [127:0] state;
    bit [127:0] key;
    
    // The Golden Truth (from the C program)
    bit [127:0] expected_out;
    
    // The actual output observed from the physical hardware
    bit [127:0] out;

    // Display function to print the transaction details nicely
    function void display(string name);
        $display("--------------------------------");
        $display("[%s]", name);
        $display("--------------------------------");
        $display("State    : %h", state);
        $display("Key      : %h", key);
        $display("Expected : %h", expected_out);
        $display("Actual   : %h", out);
        $display("--------------------------------");
    endfunction

endclass
