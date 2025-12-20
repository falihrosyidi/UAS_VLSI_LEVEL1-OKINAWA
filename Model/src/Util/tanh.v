`ifndef TANH
`define TANH

module tanh #(
    parameter WIDTH = 32,
    parameter FL = 24
) (
    input  signed [WIDTH-1:0] a,
    output signed [WIDTH-1:0] y
);
    
    // 1. Ambil tanda dan nilai absolut
    wire sign = a[WIDTH-1];
    
    // PERBAIKAN: Absolute value yang benar untuk signed number
    wire signed [WIDTH-1:0] a_pos = (a[WIDTH-1]) ? (~a + 1'b1) : a;
    wire signed [WIDTH-1:0] ai = (a_pos < 0) ? -a_pos : a_pos; // Extra safety
    
    // 2. Koefisien untuk setiap segment
    reg signed [WIDTH-1:0] p1, p2, p3;
    
    // 3. Segment selector
    always @(*) begin
        if (ai >= 32'h04000000) begin          // ai >= 4.0
            p1 = 32'h00000000;  // 0
            p2 = 32'h00000000;  // 0
            p3 = 32'h01000000;  // 1.0
        end else if (ai >= 32'h02000000) begin // 2.0 <= ai < 4.0
            // -0.012845, 0.091424, 0.836701
            p1 = 32'hFFFCB548;  // -0.012845
            p2 = 32'h001767BB;  // 0.091424
            p3 = 32'h00D63241;  // 0.836701
        end else if (ai >= 32'h01000000) begin // 1.0 <= ai < 2.0
            // -0.168637, 0.699828, 0.234964
            p1 = 32'hFFD4D359;  // -0.168637
            p2 = 32'h00B327E2;  // 0.699828
            p3 = 32'h003C26AA;  // 0.234964
        end else begin                         // 0.0 <= ai < 1.0
            // -0.330005, 1.101576, -0.006996
            p1 = 32'shFFAFE6E7;  // -0.312854
            p2 = 32'sh01143A0D;  //  1.079009
            p3 = 32'sh00000000;  //  0.000000
        end
    end
    
    // 4. Perhitungan quadratic: y_abs = p1*ai^2 + p2*ai + p3
    
    // ai^2 dalam Q8.24
    wire signed [63:0] ai_sq_full = ai * ai;
    wire signed [WIDTH-1:0] ai_sq = ai_sq_full[FL+WIDTH-1:FL];  // Ambil bit yang benar
    
    // term1 = p1 * ai_sq
    wire signed [63:0] term1_full = p1 * ai_sq;
    wire signed [WIDTH-1:0] term1 = term1_full[FL+WIDTH-1:FL];
    
    // term2 = p2 * ai
    wire signed [63:0] term2_full = p2 * ai;
    wire signed [WIDTH-1:0] term2 = term2_full[FL+WIDTH-1:FL];
    
    // y_abs = term1 + term2 + p3
    wire signed [WIDTH-1:0] y_abs = term1 + term2 + p3;
    
    // 5. PERBAIKAN: Kembalikan tanda dengan benar
    wire signed [WIDTH-1:0] y_signed;
    assign y_signed = (sign) ? (~y_abs + 1'b1) : y_abs;  // Two's complement untuk negatif
    
    // 6. PERBAIKAN: Saturasi yang benar
    // +1.0 = 0x01000000, -1.0 = 0xFF000000
    wire signed [WIDTH-1:0] ONE_POS = 32'h01000000;
    wire signed [WIDTH-1:0] ONE_NEG = 32'hFF000000;
    
    assign y = (y_signed > ONE_POS) ? ONE_POS :
               (y_signed < ONE_NEG) ? ONE_NEG : 
               y_signed;

endmodule

`endif