`timescale 1ns / 1ps
`include "top_level.v"
`default_nettype none

module tb_top_level;
    // Parameter
    localparam WIDTH = 32;
    localparam signed [WIDTH-1:0] Q_ONE  = 32'h01000000; // Nilai 1 dalam Q8.24
    localparam signed [WIDTH-1:0] Q_ZERO = 32'h00000000; // Nilai 0 dalam Q8.24

    // Inputs
    reg choice;
    reg signed [WIDTH-1:0] in_1, in_2;
    reg clk;
    reg rst;

    // Outputs
    wire signed [WIDTH-1:0] out_discriminator;
    wire signed [WIDTH-1:0] pixel_1x1, pixel_1x2, pixel_1x3;
    wire signed [WIDTH-1:0] pixel_2x1, pixel_2x2, pixel_2x3;
    wire signed [WIDTH-1:0] pixel_3x1, pixel_3x2, pixel_3x3;

    // Clock Generator
    localparam CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) clk=~clk;

    // Instansiasi Device Under Test (DUT)
    top_level #(
        .WIDTH(WIDTH)
    ) dut (
        .clk(clk), .rst(rst),
        .choice(choice), .in_1(in_1), .in_2(in_2),
        .out_discriminator(out_discriminator),
        .pixel_1x1(pixel_1x1), .pixel_1x2(pixel_1x2), .pixel_1x3(pixel_1x3),
        .pixel_2x1(pixel_2x1), .pixel_2x2(pixel_2x2), .pixel_2x3(pixel_2x3),
        .pixel_3x1(pixel_3x1), .pixel_3x2(pixel_3x2), .pixel_3x3(pixel_3x3)
    );

    // Konfigurasi Dump File
    initial begin
        $dumpfile("tb_top_level.vcd");
        $dumpvars(0, tb_top_level);
    end

    // Stimulus
    initial begin
        $display("Memulai Simulasi...");
        $display("Time | Choice | In1 | In2 | Out Disc");
        $monitor("%4t | %b | %h | %h | %h", $time, choice, in_1, in_2, out_discriminator);
        
        // DEFAULT
        clk = 0;
        rst = 1;
        in_1 = Q_ZERO;
        in_2 = Q_ZERO;
        choice = 0;

        // INITIAL VALUE
        repeat (2) @(posedge clk);
        rst <= 0;

        // --- Skenario 1: in_1 = 0, in_2 = 1 ---
        $display("--- CASE 1: 0 and 1 : CIRCLE-CROSS ---");
        in_1 <= Q_ZERO;
        in_2 <= Q_ONE;
        
        choice <= 1; // Choice 1
        @(posedge clk);

        choice <= 0; // Choice 0
        @(posedge clk);

        // --- Skenario 2: in_1 = 1, in_2 = 0 ---
        $display("--- CASE 2: 0 and 1 : CIRCLE-CROSS ---");
        in_1 <= Q_ONE;
        in_2 <= Q_ZERO;

        choice <= 1; // Choice 1
        @(posedge clk);

        choice <= 0; // Choice 0
        @(posedge clk);

        repeat (20) @(posedge clk);
        repeat (2) @(posedge clk);
        rst <= 0; 
        repeat (2) @(posedge clk);
        rst <= 1;
        repeat (2) @(posedge clk);

        $display("Simulasi Selesai.");
        $finish;
    end

endmodule
`default_nettype wire