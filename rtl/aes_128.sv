module aes_128 (
    input  logic         clk,
    input  logic [127:0] state, 
    input  logic [127:0] key,
    output logic [127:0] out
);

    logic [127:0] s0, k0;
    logic [127:0] s1, s2, s3, s4, s5, s6, s7, s8, s9,
                  k1, k2, k3, k4, k5, k6, k7, k8, k9,
                  k0b, k1b, k2b, k3b, k4b, k5b, k6b, k7b, k8b, k9b;

    // Sequential logic for Initial State and Key
    always_ff @(posedge clk) begin
        s0 <= state ^ key;
        k0 <= key;
    end

    // Key Expansion Instantiations
    expand_key_128 a1  (clk, k0, k1, k0b, 8'h1),
                   a2  (clk, k1, k2, k1b, 8'h2),
                   a3  (clk, k2, k3, k2b, 8'h4),
                   a4  (clk, k3, k4, k3b, 8'h8),
                   a5  (clk, k4, k5, k4b, 8'h10),
                   a6  (clk, k5, k6, k5b, 8'h20),
                   a7  (clk, k6, k7, k6b, 8'h40),
                   a8  (clk, k7, k8, k7b, 8'h80),
                   a9  (clk, k8, k9, k8b, 8'h1b),
                   a10 (clk, k9,   , k9b, 8'h36);

    // AES Rounds Instantiations
    one_round r1 (clk, s0, k0b, s1),
              r2 (clk, s1, k1b, s2),
              r3 (clk, s2, k2b, s3),
              r4 (clk, s3, k3b, s4),
              r5 (clk, s4, k4b, s5),
              r6 (clk, s5, k5b, s6),
              r7 (clk, s6, k6b, s7),
              r8 (clk, s7, k7b, s8),
              r9 (clk, s8, k8b, s9);

    // Final result is assigned directly to the output without conditional logic
    final_round rf (clk, s9, k9b, out);

endmodule

// =================================================================
// Math Modules (Stable Core Logic)
// =================================================================
module expand_key_128 (
    input  logic          clk,
    input  logic [127:0] in,
    output logic [127:0] out_1, 
    output logic [127:0] out_2, 
    input  logic [7:0]   rcon  
);

    logic [31:0] k0, k1, k2, k3,
                 v0, v1, v2, v3;
    logic [31:0] k0a, k1a, k2a, k3a;
    logic [31:0] k0b, k1b, k2b, k3b, k4a;

    assign {k0, k1, k2, k3} = in;
    
    assign v0 = {k0[31:24] ^ rcon, k0[23:0]};
    assign v1 = v0 ^ k1;
    assign v2 = v1 ^ k2;
    assign v3 = v2 ^ k3;

    always_ff @(posedge clk) begin
        {k0a, k1a, k2a, k3a} <= {v0, v1, v2, v3};
    end

    S4 S4_0 (clk, {k3[23:0], k3[31:24]}, k4a);

    assign k0b = k0a ^ k4a;
    assign k1b = k1a ^ k4a;
    assign k2b = k2a ^ k4a;
    assign k3b = k3a ^ k4a;

    always_ff @(posedge clk) begin
        out_1 <= {k0b, k1b, k2b, k3b};
    end

    assign out_2 = {k0b, k1b, k2b, k3b};
    
endmodule
