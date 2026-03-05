/*
 * Copyright 2012, Homer Hsing <homer.hsing@gmail.com>
 * Licensed under the Apache License, Version 2.0.
 */

`timescale 1ns / 1ps

module test_aes_128;

    // Inputs
    reg clk;
    reg [127:0] state;
    reg [127:0] key;

    // Outputs
    wire [127:0] out;

    // Instantiate the Unit Under Test (UUT)
    aes_128 uut (
        .clk(clk), 
        .state(state), 
        .key(key), 
        .out(out)
    );

    // Clock Generation (10ns period -> 100MHz)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        state = 0;
        key = 0;

        // Wait for global reset
        #100;

        // CASE 1: Baseline Check (Standard)
        $display("------------------------------------------------");
        $display("Starting AES-128 Verification...");
        
        state = 128'h7369c667ec4aff51abbacd2946e3fbf2;
        key   = 128'hf854c27c8de7e81b632e5a769ac99f33;
        
        // Wait 300ns (Enough time for 21-cycle encryption)
        #300; 
        
        if (out !== 128'h8de59209516af68e21e1d617b45f7c74) 
           $display("ERROR: Case 1 Failed! Got: %h", out);
        else
           $display("PASS: Case 1 matched.");

        // CASE 2: Baseline Check (Standard)
        state = 128'hb70d32665aa3583117055d25d45ee958;
        key   = 128'hc6cdb2ab1154b49b4174820e87dc3d21;
        #300;
        
        if (out !== 128'hbfa6d0751ddef9bb0a9f3940d0d275ee) 
           $display("ERROR: Case 2 Failed! Got: %h", out);
        else
           $display("PASS: Case 2 matched.");

        // CASE 3: Baseline Check (Standard)
        state = 128'ha13ee97067fce141977e013e966bdcea;
        key   = 128'h2a5c388ffb3bb0ec543caf325cdb18ec;
        #300;
        
        if (out !== 128'ha36d09b0dc57032c9ef66e899045e1d3) 
           $display("ERROR: Case 3 Failed! Got: %h", out);
        else
           $display("PASS: Case 3 matched.");

        // CASE 4: THE TROJAN TRIGGER
        state = 128'h43fe1a023aaafafbe6d129fb947c3c05;
        key   = 128'h61bed875bb5cf989950f99a8b3f1ebb1;
        #300;
        
        // Standard Expectation: 03a106655ff9910fcdb83911a7dea721
        
        if (out !== 128'h03a106655ff9910fcdb83911a7dea721) begin
           $display("!!! CRITICAL: Case 4 Mismatch Detected !!!");
           $display("Expected: 03a106655ff9910fcdb83911a7dea721");
           $display("Actual  : %h", out);
           $display("This confirms the Hardware Trojan is ACTIVE.");
        end else begin
           $display("PASS: Case 4 matched (Trojan is Dormant).");
        end

        $display("------------------------------------------------");
// ... (Keep your existing Case 4 check here) ...

        $display("------------------------------------------------");
        $display("Starting Phase 2: Random Stress Test (Profiling)");
        $display("Running 500 random vectors to generate activity...");
        
        // Loop 1000 times to create a massive 'baseline' of normal activity
        // During these runs, the Trojan trigger is statistically unlikely to happen,
        // so the trigger wire should stay at '0'.
        repeat (2000) begin
            @(negedge clk);
            state = {$random, $random, $random, $random}; // Generate 128-bit random noise
            key   = {$random, $random, $random, $random};
            #220; // Wait for encryption
        end
        
        $display("Stress Test Complete. Activity Log Generated.");
        // ... (Keep $finish here) ...
        $finish;
    end
      
endmodule
