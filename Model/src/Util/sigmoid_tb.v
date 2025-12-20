`timescale 1ns / 1ps
`include "sigmoid.v"

module sigmoid_tb();

    reg  signed [31:0] x;
    wire signed [31:0] y;

    // Instansiasi Unit Under Test (UUT)
    sigmoid uut (
        .x(x),
        .y(y)
    );

    // Fungsi pembantu untuk menampilkan nilai dalam format desimal (aproksimasi)
    // Karena 2^24 = 16777216
    task display_q8_24;
        input signed [31:0] val;
        real r_val;
        begin
            r_val = $itor(val) / 16777216.0;
            $write("%f (Hex: %h)", r_val, val);
        end
    endtask

    initial begin
        $display("------------------------------------------------------------");
        $display("Testing Sigmoid PWL Q8.24 Implementation");
        $display("------------------------------------------------------------");

        // Test Case 1: x = 0 (Expected y = 0.5)
        x = 32'h00000000; 
        #10;
        $write("In: 0.00 | Out: "); display_q8_24(y); $display("");

        // Test Case 2: x = 0.5 (Segmen 1, abs_x < 1)
        // 0.5 * 2^24 = 8388608 = 32'h00800000
        x = 32'h00800000; 
        #10;
        $write("In: 0.50 | Out: "); display_q8_24(y); $display(" (Exp: 0.625)");

        // Test Case 3: x = 2.0 (Segmen 2, 1 < abs_x < 2.375)
        // 2.0 * 2^24 = 33554432 = 32'h02000000
        x = 32'h02000000; 
        #10;
        $write("In: 2.00 | Out: "); display_q8_24(y); $display(" (Exp: 0.875)");

        // Test Case 4: x = 4.0 (Segmen 3, 2.375 < abs_x < 5)
        // 4.0 * 2^24 = 67108864 = 32'h04000000
        x = 32'h04000000; 
        #10;
        $write("In: 4.00 | Out: "); display_q8_24(y); $display(" (Exp: 0.96875)");

        // Test Case 5: x = 6.0 (Saturasi, abs_x > 5)
        x = 32'h06000000; 
        #10;
        $write("In: 6.00 | Out: "); display_q8_24(y); $display(" (Exp: 1.0)");

        // Test Case 6: x = -1.0 (Simetri, Expected y = 1 - sigmoid(1))
        // Sigmoid(1) v1 = 0.25(1) + 0.5 = 0.75. Maka y = 1 - 0.75 = 0.25
        x = -32'h01000000; 
        #10;
        $write("In:-1.00 | Out: "); display_q8_24(y); $display(" (Exp: 0.25)");

        // Test Case 7: x = -4.0 (Simetri)
        x = -32'h04000000; 
        #10;
        $write("In:-4.00 | Out: "); display_q8_24(y); $display("");

        $display("------------------------------------------------------------");
        $finish;
    end

endmodule