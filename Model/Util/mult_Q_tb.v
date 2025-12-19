`timescale 1ns / 1ps
`include "mult_Q.v"

module tb_mult_Q();
    // Parameter disesuaikan dengan modul mult_Q 
    parameter WIDTH = 32;
    parameter FBITS = 27;

    reg signed [WIDTH-1:0] a, b;
    wire signed [WIDTH-1:0] y;

    // Scaling Factor: 2^-27 untuk mengonversi integer ke real
    localparam real SF = 2.0**-FBITS;

    // Instansiasi modul mult_Q 
    mult_Q #(
        .WIDTH(WIDTH),
        .FBITS(FBITS)
    ) uut (
        .a(a),
        .b(b),
        .y(y)
    );

    initial begin
        $display("Fixed Point Multiplication Test (Q%0d.%0d)", WIDTH-FBITS, FBITS);
        $display("--------------------------------------------------");

        // Contoh 1: 1.5 * 2.0 = 3.0
        // 1.5 dalam Q5.27 adalah 1.5 * 2^27
        a = 1.5 * (2**FBITS); 
        b = 2.0 * (2**FBITS);
        #10;
        $display("%f * %f = %f", $itor(a)*SF, $itor(b)*SF, $itor(y)*SF);

        // Contoh 2: 0.5 * 0.5 = 0.25
        a = 0.5 * (2**FBITS);
        b = 0.5 * (2**FBITS);
        #10;
        $display("%f * %f = %f", $itor(a)*SF, $itor(b)*SF, $itor(y)*SF);

        // Contoh 3: Bilangan Negatif (-1.25 * 4.0 = -5.0)
        a = -1.25 * (2**FBITS);
        b = 4.0 * (2**FBITS);
        #10;
        $display("%f * %f = %f", $itor(a)*SF, $itor(b)*SF, $itor(y)*SF);

        // Contoh 4: Perkalian angka kecil
        a = 0.125 * (2**FBITS);
        b = 0.25 * (2**FBITS);
        #10;
        $display("%f * %f = %f", $itor(a)*SF, $itor(b)*SF, $itor(y)*SF);

        $display("--------------------------------------------------");
        $finish;
    end
endmodule