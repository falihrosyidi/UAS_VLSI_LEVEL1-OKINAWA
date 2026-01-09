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
    localparam [WIDTH-1:0] TH_15  = 32'h01800000; // 1.5
    localparam [WIDTH-1:0] TH_35  = 32'h03800000; // 3.5  
    localparam [WIDTH-1:0] TH_60  = 32'h06000000; // 6.0
    
    always @(*) begin
        if (a_pos >= TH_60) begin          // a_pos >= 6.0
            p1 = 32'h00000000;  // 0
            p2 = 32'h00000000;  // 0
            p3 = 32'h01000000;  // 1.0 (untuk f(|x|))
        end else if (a_pos >= TH_35) begin // 3.5 <= a_pos < 6.0
            p1 = 32'hFFFF2E17;  // -0.0046090
            p2 = 32'h000DBB00;  // 0.053606
            p3 = 32'h00D74205;  // 0.840844
        end else if (a_pos >= TH_15) begin // 1.5 <= a_pos < 3.5
            p1 = 32'hFFFB337E;  // -0.029988
            p2 = 32'h003956F5;  // 0.223978
            p3 = 32'h008D388E;  // 0.551643
        end else begin                     // 0.0 <= a_pos < 1.5
            p1 = 32'hFFFA1546;  // -0.036623
            p2 = 32'h0044E3D8;  // 0.269097
            p3 = 32'h007F71A3;  // 0.497822 ≈ 0.5
        end
    end
    
    // 3. Pipeline Stage 1 - Register Koefisien
    wire sign_reg;
    wire signed [WIDTH-1:0] a_pos_reg, p1_reg, p2_reg, p3_reg;
    
    register #(.WIDTH(1)) reg_sign (.clk(clk), .en(en), .rst(rst), .in(sign), .out(sign_reg));
    register #(.WIDTH(WIDTH)) reg_a_pos (.clk(clk), .en(en), .rst(rst), .in(a_pos), .out(a_pos_reg));
    register #(.WIDTH(WIDTH)) reg_p1 (.clk(clk), .en(en), .rst(rst), .in(p1), .out(p1_reg));
    register #(.WIDTH(WIDTH)) reg_p2 (.clk(clk), .en(en), .rst(rst), .in(p2), .out(p2_reg));
    register #(.WIDTH(WIDTH)) reg_p3 (.clk(clk), .en(en), .rst(rst), .in(p3), .out(p3_reg));
    
    // 4. Hitung a_pos^2
    wire signed [63:0] a_sq_full = a_pos_reg * a_pos_reg;
    wire signed [WIDTH-1:0] a_sq = a_sq_full[FL+WIDTH-1:FL];
    
    wire signed [WIDTH-1:0] a_sq_reg;
    register #(.WIDTH(WIDTH)) reg_a_sq (.clk(clk), .en(en), .rst(rst), .in(a_sq), .out(a_sq_reg));
    
    // 5. Multiply
    wire signed [63:0] term1_full = p1_reg * a_sq_reg;
    wire signed [63:0] term2_full = p2_reg * a_pos_reg;
    
    wire signed [WIDTH-1:0] term1 = term1_full[FL+WIDTH-1:FL];
    wire signed [WIDTH-1:0] term2 = term2_full[FL+WIDTH-1:FL];
    
    // wire signed [WIDTH-1:0] term1_reg, term2_reg;
    // register #(.WIDTH(WIDTH)) reg_term1 (.clk(clk), .en(en), .rst(rst), .in(term1), .out(term1_reg));
    // register #(.WIDTH(WIDTH)) reg_term2 (.clk(clk), .en(en), .rst(rst), .in(term2), .out(term2_reg));
    
    // 6. Accumulate
    localparam [WIDTH-1:0] ONE = 32'h01000000;
    localparam [WIDTH-1:0] ZERO = 32'h00000000;
    
    wire signed [WIDTH-1:0] y_abs = term1 + term2 + p3_reg;
    
    // Saturasi: 0 ≤ y_abs ≤ 1
    wire signed [WIDTH-1:0] y_abs_sat = 
        (y_abs > ONE) ? ONE : 
        (y_abs < ZERO) ? ZERO : y_abs;
    
    // Apply symmetry: f(-x) = 1 - f(x)
    wire signed [WIDTH-1:0] y_sigmoid_val = 
        (sign_reg) ? (ONE - y_abs_sat) : y_abs_sat;
    
    // 7. Pipeline Stage 2 - Output
    register #(.WIDTH(WIDTH)) reg_out (.clk(clk), .en(en), .rst(rst), .in(y_sigmoid_val), .out(y));

endmodule