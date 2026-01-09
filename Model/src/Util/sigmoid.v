`ifndef SIGMOID
`define SIGMOID

// `include "register.v" // Use when only run this module
`include "Util/register.v" // Use to able run the neuron module

module sigmoid #(
    parameter WIDTH = 32,
    parameter FL = 24
) (
    // Control Signal
    input  clk, en, rst,

    // Data Signal
    input  signed [WIDTH-1:0] a,
    output signed [WIDTH-1:0] y
);
    
    // 1. Ambil tanda dan nilai absolut
    wire sign = a[WIDTH-1];
    
    // Nilai absolut untuk input signed
    wire signed [WIDTH-1:0] a_pos = (a[WIDTH-1]) ? (-a) : a;
    
    // 2. Koefisien untuk setiap segment
    reg signed [WIDTH-1:0] p1, p2, p3;
    
    // 3. Segment selector (Kombinatorial)
    always @(*) begin
        if (a_pos >= 32'h06000000) begin          // a_pos >= 6.0
            p1 = 32'h00000000;  // 0
            p2 = 32'h00000000;  // 0
            p3 = 32'h01000000;  // 1.0
        end else if (a_pos >= 32'h03800000) begin // 3.5 <= a_pos < 6.0
            p1 = 32'hFFFF2E17;  // -0.0046090
            p2 = 32'h000DBB00;  // 0.053606
            p3 = 32'h00D74205;  // 0.840844
        end else if (a_pos >= 32'h01800000) begin // 1.5 <= a_pos < 3.5
            p1 = 32'hFFFB337E;  // -0.029988
            p2 = 32'h003956F5;  // 0.223978
            p3 = 32'h008D388E;  // 0.551643
        end else begin                          // 0.0 <= a_pos < 1.5
            p1 = 32'hFFFA1546;  // -0.036623
            p2 = 32'h0044E3D8;  // 0.269097
            p3 = 32'h007F71A3;  // 0.497822
        end
    end
    
    // 4. Perhitungan quadratic: y_abs = p1*a_pos^2 + p2*a_pos + p3
    
    // a_pos^2 dalam Q8.24
    wire signed [63:0] a_pos_sq_full = a_pos * a_pos;
    wire signed [WIDTH-1:0] a_pos_sq = a_pos_sq_full[FL+WIDTH-1:FL];

    // --- PIPELINE STAGE 1 ---
    wire sign_reg;
    wire signed [WIDTH-1:0] a_pos_sq_reg, a_pos_reg, p1_reg, p2_reg, p3_reg;

    register #(.WIDTH(1)) reg_sign (
        .clk(clk), .en(en), .rst(rst),
        .in(sign), .out(sign_reg)
    );

    register #(.WIDTH(WIDTH)) reg_a_pos_sq (
        .clk(clk), .en(en), .rst(rst),
        .in(a_pos_sq), .out(a_pos_sq_reg)
    );

    register #(.WIDTH(WIDTH)) reg_a_pos (
        .clk(clk), .en(en), .rst(rst),
        .in(a_pos), .out(a_pos_reg)
    );

    register #(.WIDTH(WIDTH)) reg_p1 (
        .clk(clk), .en(en), .rst(rst),
        .in(p1), .out(p1_reg)
    );

    register #(.WIDTH(WIDTH)) reg_p2 (
        .clk(clk), .en(en), .rst(rst),
        .in(p2), .out(p2_reg)
    );

    register #(.WIDTH(WIDTH)) reg_p3 (
        .clk(clk), .en(en), .rst(rst),
        .in(p3), .out(p3_reg)
    );

    // Perhitungan Term
    wire signed [63:0] term1_full = p1_reg * a_pos_sq_reg;
    wire signed [WIDTH-1:0] term1 = term1_full[FL+WIDTH-1:FL];
    
    wire signed [63:0] term2_full = p2_reg * a_pos_reg;
    wire signed [WIDTH-1:0] term2 = term2_full[FL+WIDTH-1:FL];
    
    // Hasil kuadratik sementara
    wire signed [WIDTH-1:0] y_abs = term1 + term2 + p3_reg;
    
    // 5. PERBAIKAN LOGIKA: Simetri Sigmoid (f(-x) = 1 - f(x))
    wire signed [WIDTH-1:0] ONE_POS = 32'h01000000; // 1.0 dalam Q8.24
    
    // Saturasi atas untuk y_abs (mencegah nilai > 1.0 akibat error pendekatan)
    wire signed [WIDTH-1:0] y_abs_sat = (y_abs > ONE_POS) ? ONE_POS : 
                                        (y_abs < 32'h00000000) ? 32'h00000000 : y_abs;
    
    // Jika input negatif, y = 1 - y_abs. Jika positif, y = y_abs.
    wire signed [WIDTH-1:0] y_sigmoid_val;
    assign y_sigmoid_val = (sign_reg) ? (ONE_POS - y_abs_sat) : y_abs_sat;

    // --- PIPELINE STAGE 2 (OUTPUT) ---
    register #(.WIDTH(WIDTH)) reg_out (
        .clk(clk), .en(en), .rst(rst),
        .in(y_sigmoid_val), .out(y)
    );

endmodule

`endif