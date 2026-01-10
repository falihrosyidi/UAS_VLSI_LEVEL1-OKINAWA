`ifndef SIGMOID
`define SIGMOID

// `include "register.v" // Use when only run this module
`include "Util/register.v" // Use to able run the neuron module

module sigmoid #(
    parameter WIDTH = 32,
    parameter FL = 24
) (
    input clk, en, rst,
    input signed [WIDTH-1:0] a,
    output signed [WIDTH-1:0] y
);
    
    // 1. Ambil tanda dan nilai absolut
    wire sign = a[WIDTH-1];
    wire signed [WIDTH-1:0] a_pos = (sign) ? (-a) : a;
    
    // 2. Koefisien untuk setiap segment
    reg signed [WIDTH-1:0] p1, p2, p3;
    
    // Threshold dalam Q8.24
    localparam signed [WIDTH-1:0] TH_15  = 32'h01800000; // 1.5
    localparam signed [WIDTH-1:0] TH_35  = 32'h03800000; // 3.5
    localparam signed [WIDTH-1:0] TH_60  = 32'h06000000; // 6.0
    
    reg [1:0] sel_p;

    always @(*) begin
        if (a_pos >= TH_60) begin          // a_pos >= 6.0
            sel_p = 2'b00;
        end else if (a_pos >= TH_35) begin // 3.5 <= a_pos < 6.0
            sel_p = 2'b01;
        end else if (a_pos >= TH_15) begin // 1.5 <= a_pos < 3.5
            sel_p = 2'b10;
        end else begin                     // 0.0 <= a_pos < 1.5
            sel_p = 2'b11;
        end
    end
    
    // 3. Hitung a_pos^2
    wire signed [WIDTH*2-1:0] a_sq_full = a * a;
    wire signed [WIDTH-1:0] a_sq = a_sq_full[FL+WIDTH-1:FL];
    
    // 4. Pipeline Stage 1 - Register Koefisien
    wire sign_reg;
    wire [1:0] sel_p_reg;
    wire signed [WIDTH-1:0] a_pos_reg, a_sq_reg;
    
    register #(.WIDTH(1)) reg_sign (.clk(clk), .en(en), .rst(rst), .in(sign), .out(sign_reg));
    register #(.WIDTH(2)) reg_sel_p (.clk(clk), .en(en), .rst(rst), .in(sel_p), .out(sel_p_reg));
    register #(.WIDTH(WIDTH)) reg_a_pos (.clk(clk), .en(en), .rst(rst), .in(a_pos), .out(a_pos_reg));
    register #(.WIDTH(WIDTH)) reg_a_sq (.clk(clk), .en(en), .rst(rst), .in(a_sq), .out(a_sq_reg));

    always @(*) begin
        case (sel_p_reg)
            2'b00  : begin
                p1 = 32'h00000000;  // 0
                p2 = 32'h00000000;  // 0
            end
            2'b01  : begin
                // -0.004609, 0.053606, 0.840844
                p1 = 32'hFFFED1F2;  // -0.004609
                p2 = 32'h000DB91F;  // 0.053606
            end
            2'b10  : begin
                // -0.029988, 0.223978, 0.551643
                p1 = 32'hFFF852B5;  // -0.029988
                p2 = 32'h0039569F;  // 0.223978
            end
            2'b11  : begin
                // -0.036623, 0.269097, 0.497822
                p1 = 32'hFFF69FE0;  // -0.036623
                p2 = 32'h0044E38A;  // 0.269097
            end
            default: begin
                p1 = 32'h00000000;  // 0
                p2 = 32'h00000000;  // 0
            end
        endcase
    end
    
    // 5. Multiply
    wire signed [WIDTH*2-1:0] term1_full = p1 * a_sq_reg;
    wire signed [WIDTH*2-1:0] term2_full = p2 * a_pos_reg;
    
    wire signed [WIDTH-1:0] term1 = term1_full[FL+WIDTH-1:FL];
    wire signed [WIDTH-1:0] term2 = term2_full[FL+WIDTH-1:FL];

    // PIPELINE STAGE 2
    wire sign_reg2;
    wire [1:0] sel_p_reg2;
    wire signed [WIDTH-1:0] term1_reg, term2_reg;

    register #(.WIDTH(1)) reg_sign2 (.clk(clk), .en(en), .rst(rst), .in(sign_reg), .out(sign_reg2));
    register #(.WIDTH(2)) reg_sel_p2 (.clk(clk), .en(en), .rst(rst), .in(sel_p_reg), .out(sel_p_reg2));
    register #(.WIDTH(WIDTH)) reg_term1 (.clk(clk), .en(en), .rst(rst), .in(term1), .out(term1_reg));
    register #(.WIDTH(WIDTH)) reg_term2 (.clk(clk), .en(en), .rst(rst), .in(term2), .out(term2_reg));

    always @(*) begin
        case (sel_p_reg2)
            2'b00  : begin
                p3 = 32'h01000000;  // 1.0 (untuk f(|x|))
            end
            2'b01  : begin
                // -0.004609, 0.053606, 0.840844
                p3 = 32'h00D7418D;  // 0.840844
            end
            2'b10  : begin
                // -0.029988, 0.223978, 0.551643
                p3 = 32'h008D387A;  // 0.551643
            end
            2'b11  : begin
                // -0.036623, 0.269097, 0.497822
                p3 = 32'h007F7143;  // 0.497822
            end
            default: begin
                p3 = 32'h01000000;  // 1.0 (untuk f(|x|))
            end
        endcase
    end
    
    // 6. Accumulate
    localparam signed [WIDTH-1:0] ONE = 32'h01000000;
    localparam signed [WIDTH-1:0] ZERO = 32'h00000000;
    
    wire signed [WIDTH-1:0] y_abs = term1_reg + term2_reg + p3;
    
    // Saturasi: 0 ≤ y_abs ≤ 1
    wire signed [WIDTH-1:0] y_abs_sat = 
        (y_abs > ONE) ? ONE : 
        (y_abs < ZERO) ? ZERO : y_abs;
    
    // Apply symmetry: f(-x) = 1 - f(x)
    wire signed [WIDTH-1:0] y_sigmoid_val = 
        (sign_reg2) ? (ONE - y_abs_sat) : y_abs_sat;
    
    // 7. Pipeline Stage 2 - Output
    register #(.WIDTH(WIDTH)) reg_out (.clk(clk), .en(en), .rst(rst), .in(y_sigmoid_val), .out(y));

endmodule
`endif 