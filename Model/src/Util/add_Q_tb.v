`timescale 1ns / 1ps
`include "add_Q.v"

module tb_add_Q();
    // Parameter disesuaikan dengan modul add_Q 
    parameter WIDTH = 32;
    parameter FBITS = 27;

    reg signed [WIDTH-1:0] a, b;
    wire signed [WIDTH-1:0] y;

    // Scaling Factor: 2^-27 untuk mengonversi nilai integer kembali ke desimal real
    localparam real SF = 2.0**-FBITS;

    // Instansiasi modul (menggunakan nama mult_Q sesuai source code )
    mult_Q #(
        .WIDTH(WIDTH),
        .FBITS(FBITS)
    ) uut (
        .a(a), // 
        .b(b), // 
        .y(y)  // 
    );

    initial begin
        $display("Fixed Point Addition Test (Q%0d.%0d)", WIDTH-FBITS, FBITS);
        $display("--------------------------------------------------");

        // Contoh 1: 1.25 + 0.75 = 2.0
        a = 1.25 * (2**FBITS); 
        b = 0.75 * (2**FBITS);
        #10;
        $display("%f + %f = %f", $itor(a)*SF, $itor(b)*SF, $itor(y)*SF);

        // Contoh 2: 5.0 + (-2.5) = 2.5
        a = 5.0 * (2**FBITS);
        b = -2.5 * (2**FBITS);
        #10;
        $display("%f + %f = %f", $itor(a)*SF, $itor(b)*SF, $itor(y)*SF);

        // Contoh 3: -1.0 + (-1.0) = -2.0
        a = -1.0 * (2**FBITS);
        b = -1.0 * (2**FBITS);
        #10;
        $display("%f + %f = %f", $itor(a)*SF, $itor(b)*SF, $itor(y)*SF);

        // Contoh 4: Angka sangat kecil
        a = 0.0000001 * (2**FBITS);
        b = 0.0000002 * (2**FBITS);
        #10;
        $display("%f + %f = %f", $itor(a)*SF, $itor(b)*SF, $itor(y)*SF);

        $display("--------------------------------------------------");
        $finish;
    end
endmodule