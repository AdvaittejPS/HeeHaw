class aes_transaction;

    // 'rand' keyword tells the Generator to randomize these fields
    rand bit [127:0] state;
    rand bit [127:0] key;
    
    // Output is not random; we observe it from the DUT
    bit [127:0] out;

    // Display function to print the transaction details nicely
    function void display(string name);
        $display("--------------------------------");
        $display("[%s]", name);
        $display("--------------------------------");
        $display("State : %h", state);
        $display("Key   : %h", key);
        $display("Out   : %h", out);
        $display("--------------------------------");
    endfunction

endclass
