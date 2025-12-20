`ifndef TANH
`define TANH

module tanh #(
    parameter WIDTH = 32,
    parameter FL = 24  // Diubah menjadi 24
) (
    input  signed [WIDTH-1:0] a,
    output signed [WIDTH-1:0] y
);
    // 1. Ambil nilai Absolut dan Simpan Tanda (Sign)
    wire sign = a[WIDTH-1];
    wire signed [WIDTH-1:0] ai = (sign) ? -a : a;

    // 2. Register untuk Koefisien (Dihitung ulang untuk Q8.24)
    reg signed [WIDTH-1:0] p1, p2, p3;

    // 3. Segment Selector Logic
    // 4.0 = 0x04000000, 2.0 = 0x02000000, 1.0 = 0x01000000
    always @(*) begin
        if (ai >= 32'h04000000) begin          // ai >= 4.0
            p1 = 32'h00000000; p2 = 32'h00000000; p3 = 32'h01000000; // y = 1.0
        end else if (ai >= 32'h02000000) begin // 2.0 <= ai < 4.0
            p1 = 32'hFFFCB548; p2 = 32'h001767BB; p3 = 32'h00D63241;
        end else if (ai >= 32'h01000000) begin // 1.0 <= ai < 2.0
            p1 = 32'hFFD4D359; p2 = 32'h00B327E2; p3 = 32'h003C26AA;
        end else begin                         // 0.0 <= ai < 1.0
            p1 = 32'hFFAB661E; p2 = 32'h011A0310; p3 = 32'hFFFE3586;
        end
    end
    
    // 4. Perhitungan Quadratic: y = (p1 * ai^2) + (p2 * ai) + p3
    // ai_sq = (ai * ai) >>> 24
    wire signed [63:0] ai_sq_full = (ai * ai);
    wire signed [WIDTH-1:0] ai_sq = ai_sq_full >>> FL; 
    
    // term1 = p1 * ai_sq (Q8.24 * Q8.24 -> ambil Q8.24)
    wire signed [63:0] term1_full = (p1 * ai_sq);
    wire signed [WIDTH-1:0] term1 = term1_full >>> FL;
    
    // term2 = p2 * ai (Q8.24 * Q8.24 -> ambil Q8.24)
    wire signed [63:0] term2_full = (p2 * ai);
    wire signed [WIDTH-1:0] term2 = term2_full >>> FL;

    // Jumlahkan semua (y_abs = term1 + term2 + p3)
    wire signed [WIDTH-1:0] y_abs = term1 + term2 + p3;

    // 5. Kembalikan Tanda dan Saturasi
    wire signed [WIDTH-1:0] y_combined = (sign) ? -y_abs : y_abs;

    // Saturasi pada rentang [-1.0, 1.0] atau [0xFF000000, 0x01000000]
    assign y = (y_combined > 32'h01000000)  ? 32'h01000000 :
               (y_combined < -32'h01000000) ? -32'h01000000 : y_combined;

endmodule

`endif