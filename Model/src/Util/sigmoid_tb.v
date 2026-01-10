`timescale 1ns / 1ps
`include "sigmoid.v"


module sigmoid_tb();

    // Parameters
    parameter WIDTH = 32;
    parameter FL = 24;

    // Signals
    reg clk;
    reg en;
    reg rst;
    reg signed [WIDTH-1:0] x; // Kita hubungkan ke port 'a' di modul
    wire signed [WIDTH-1:0] y;

    // Instansiasi Unit Under Test (UUT)
    sigmoid #(
        .WIDTH(WIDTH),
        .FL(FL)
    ) uut (
        .clk(clk),
        .en(en),
        .rst(rst),
        .a(x), // Port 'a' dihubungkan ke reg 'x'
        .y(y)
    );

    // Clock Generator (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Fungsi pembantu untuk menampilkan nilai Q8.24
    task display_q8_24;
        input signed [31:0] val;
        real r_val;
        begin
            r_val = $itor(val) / 16777216.0; // 2^24
            $write("%f (Hex: %h)", r_val, val);
        end
    endtask

    // Task untuk memberikan input dan menunggu pipeline (3-4 cycle)
    task test_value;
        input signed [31:0] val_in;
        begin
            x = val_in;
            @(posedge clk);
            // Menunggu 3 cycle agar data sampai ke output register
            repeat(3) @(posedge clk);
            $write("In: "); display_q8_24(val_in);
            $write(" | Out: "); display_q8_24(y);
            $display("");
        end
    endtask

    initial begin
        // Setup VCD
        $dumpfile("sigmoid_sim.vcd");
        $dumpvars(0, sigmoid_tb);

        // Initialize
        rst = 1;
        en = 0;
        x = 0;

        $display("------------------------------------------------------------");
        $display("Testing Pipelined Sigmoid Quadratic Implementation");
        $display("------------------------------------------------------------");

        #20;
        rst = 0;
        en = 1;
        @(posedge clk);

        // Test Case 1: x = -5
        test_value(32'hfb000000);

        // Test Case 2: x = -2.5 (Q24: 00800000)
        test_value(32'hfd800000);

        // Test Case 3: x = 0 (Q24: 02000000)
        test_value(32'h00000000);

        // Test Case 4: x = 2.5 (Q24: 04000000)
        test_value(32'h02800000);

        // Test Case 5: x = 5 (Saturasi 1.0)
        test_value(32'h05000000);


        $display("------------------------------------------------------------");
        $display("Simulasi Selesai. Cek file sigmoid_sim.vcd");
        $finish;
    end

endmodule