`include "aes_environment.sv"

program test(aes_interface intf);
    
    // Declare the environment
    aes_environment env;

    initial begin
        // Construct the environment and pass it the interface
        env = new(intf);
        
        // Configure the stress test! 
        // We want 2000 high-entropy packets to trigger normal switching activity
        env.gen.repeat_count = 2000;
        
        // Start the verification process
        env.run();
    end

endprogram
