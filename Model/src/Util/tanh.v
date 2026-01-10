`ifndef TANH
`define TANH

// `include "register.v" // Use when only run this module
`include "Util/register.v" // Use to able run the neuron module

module tanh #(
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
    
    // PERBAIKAN: Absolute value yang benar untuk signed number
    wire signed [WIDTH-1:0] a_pos = (a[WIDTH-1]) ? (-a) : a;
    
    // 2. Koefisien untuk setiap segment
    reg signed [WIDTH-1:0] p1, p2, p3;
    reg [1:0] sel_p;
    
    // 3. Segment selector
    always @(*) begin
        if (a_pos >= 32'h04000000) begin          // a_pos >= 4.0
            sel_p = 2'b00;
        end else if (a_pos >= 32'h02000000) begin // 2.0 <= a_pos < 4.0
            sel_p = 2'b01;
        end else if (a_pos >= 32'h01000000) begin // 1.0 <= a_pos < 2.0
            sel_p = 2'b10;
        end else begin                         // 0.0 <= a_pos < 1.0
            sel_p = 2'b11;
        end
    end
    
    // 4. Perhitungan quadratic: y_abs = p1*a_pos^2 + p2*a_pos + p3
    
    // a_pos^2 dalam Q8.24
    wire signed [63:0] a_pos_sq_full = a_pos * a_pos;
    wire signed [WIDTH-1:0] a_pos_sq = a_pos_sq_full[FL+WIDTH-1:FL];  // Ambil bit yang benar

    // PIPELINE
    wire signed sign_reg;
    wire [3:0] sel_p_in;
    wire [3:0] sel_p_reg;
    wire signed [WIDTH-1:0] a_pos_sq_reg, a_pos_reg;

    register #(.WIDTH(1)) reg_sign (
        .clk(clk), .en(en), .rst(rst),
        .in(sign), .out(sign_reg)
    );

    assign sel_p_in = {sel_p_reg[1:0], sel_p};
    register #(.WIDTH(4)) reg_sel_p12 (
        .clk(clk), .en(en), .rst(rst),
        .in(sel_p_in), .out(sel_p_reg)
    );

    register #(.WIDTH(WIDTH)) reg_a_pos_sq (
        .clk(clk), .en(en), .rst(rst),
        .in(a_pos_sq), .out(a_pos_sq_reg)
    );

    register #(.WIDTH(WIDTH)) reg_a_pos (
        .clk(clk), .en(en), .rst(rst),
        .in(a_pos), .out(a_pos_reg)
    );

    always @(*) begin
        case (sel_p_reg[1:0])
            2'b00  : begin
                p1 = 32'h00000000;  // 0
                p2 = 32'h00000000;  // 0
            end
            2'b01  : begin
                // -0.012845, 0.091424, 0.836701
                p1 = 32'hFFFCB548;  // -0.012845
                p2 = 32'h001767BB;  // 0.091424
            end
            2'b10  : begin
                // -0.168637, 0.699828, 0.234964
                p1 = 32'hFFD4D35C;  // -0.168637
                p2 = 32'h00B327E0;  // 0.699828
            end
            2'b11  : begin
                // -0.330005, 1.101576, -0.006996
                p1 = 32'hFFAB84CB;  // -0.330005
                p2 = 32'h011A00E2;  // 1.101576
            end
            default: begin
                p1 = 32'h00000000;  // 0
                p2 = 32'h00000000;  // 0
            end
        endcase
    end
    
    // term1 = p1 * a_pos_sq
    wire signed [63:0] term1_full = p1 * a_pos_sq_reg;
    wire signed [WIDTH-1:0] term1 = term1_full[FL+WIDTH-1:FL];
    
    // term2 = p2 * a_pos
    wire signed [63:0] term2_full = p2 * a_pos_reg;
    wire signed [WIDTH-1:0] term2 = term2_full[FL+WIDTH-1:FL];

    // PIPELINE 2
    wire signed [WIDTH-1:0] term1_reg, term2_reg;

    register #(.WIDTH(WIDTH)) reg_term1 (
        .clk(clk), .en(en), .rst(rst),
        .in(term1), .out(term1_reg)
    );

    register #(.WIDTH(WIDTH)) reg_term2 (
        .clk(clk), .en(en), .rst(rst),
        .in(term2), .out(term2_reg)
    );

    always @(*) begin
        case (sel_p_reg[3:2])
            2'b00  : begin
                p3 = 32'h01000000;  // 1.0
            end
            2'b01  : begin
                // -0.012845, 0.091424, 0.836701
                p3 = 32'h00D63241;  // 0.836701
            end
            2'b10  : begin
                // -0.168637, 0.699828, 0.234964
                p3 = 32'h003C26AA;  // 0.234964
            end
            2'b11  : begin
                // -0.330005, 1.101576, -0.006996
                p3 = 32'hFFFE3583;  // -0.006996
            end
            default: begin
                p3 = 32'h01000000;  // 1.0
            end
        endcase
    end

    // y_abs = term1 + term2 + p3
    wire signed [WIDTH-1:0] y_abs = term1_reg + term2_reg + p3;
    
    // 5. PERBAIKAN: Kembalikan tanda dengan benar
    wire signed [WIDTH-1:0] y_signed;
    assign y_signed = (sign_reg) ? (-y_abs) : y_abs;  // Two's complement untuk negatif
    
    // 6. PERBAIKAN: Saturasi yang benar
    // +1.0 = 0x01000000, -1.0 = 0xFF000000
    wire signed [WIDTH-1:0] ONE_POS = 32'h01000000;
    wire signed [WIDTH-1:0] ONE_NEG = 32'hFF000000;
    
    wire signed [WIDTH-1:0] y_in = (y_signed > ONE_POS) ? ONE_POS :
                                (y_signed < ONE_NEG) ? ONE_NEG : y_signed;

    // PIPELINE OUTPUT
    register #(.WIDTH(WIDTH)) reg_out (
        .clk(clk), .en(en), .rst(rst),
        .in(y_in), .out(y)
    );

endmodule

`endif