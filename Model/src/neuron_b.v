`ifndef NEURON_B
`define NEURON_B

`include "Util/tanh.v"
`include "Util/mult_Q.v"
`include "Util/register.v"

module neuron_b #(
    parameter WIDTH = 32
) (
    // Control Signal
    input  clk, en, rst,

    // Data Signal
    input signed [WIDTH-1:0] a_1, a_2, a_3, a_4, a_5, a_6, a_7, a_8, a_9,
    input  signed [WIDTH-1:0] w_1, w_2, w_3, w_4, w_5, w_6, w_7, w_8, w_9,
    input signed [WIDTH-1:0] b,
    output signed [WIDTH-1:0] y
);  

    wire signed [WIDTH-1:0] a_arr [1:9];
    wire signed [WIDTH-1:0] w_arr [1:9];
    // Hasil Perkalian (a * w)
    wire signed [WIDTH-1:0] m  [1:9]; 
    // Hasil penjumlahan hasil perkalian dan bias
    wire signed [WIDTH-1:0]  total_sum ;

    assign a_arr[1] = a_1; assign a_arr[2] = a_2; assign a_arr[3] = a_3;
    assign a_arr[4] = a_4; assign a_arr[5] = a_5; assign a_arr[6] = a_6;
    assign a_arr[7] = a_7; assign a_arr[8] = a_8; assign a_arr[9] = a_9;

    assign w_arr[1] = w_1; assign w_arr[2] = w_2; assign w_arr[3] = w_3;
    assign w_arr[4] = w_4; assign w_arr[5] = w_5; assign w_arr[6] = w_6;
    assign w_arr[7] = w_7; assign w_arr[8] = w_8; assign w_arr[9] = w_9;

    // SIGNAL OUTPUT PIPELINE MULT
    wire signed [WIDTH-1:0] m_reg [1:9];

    genvar i;
    generate
        for (i = 1; i <= 9 ; i = i + 1) begin
            mult_Q #(.WIDTH(32), .FBITS(24)) multiplier (
                .a(a_arr[i]), 
                .b(w_arr[i]), 
                .y(m[i])
            );
            // PIPELINE OUT MULT
            register #(.WIDTH(WIDTH)) reg_mult (
                .clk(clk), .en(en), .rst(rst),
                .in(m[i]), .out(m_reg[i])
            );
        end
    endgenerate
    
    assign total_sum =  m_reg[1] + m_reg[2] + m_reg[3] +
                        m_reg[4] + m_reg[5] + m_reg[6] +
                        m_reg[7] + m_reg[8] + m_reg[9] + b;

    // PIPELINE
    wire signed [WIDTH-1:0] total_sum_reg;
    register #(.WIDTH(WIDTH)) reg_total_sum (
        .clk(clk), .en(en), .rst(rst),
        .in(total_sum), .out(total_sum_reg)
    );

    // TANH <= ACTIVATE FUNCTION
    tanh activate_func (
        .clk(clk), .en(en), .rst(rst),
        .a(total_sum_reg), .y(out)
    );
    wire signed [WIDTH-1:0] out;

    assign y = out;
endmodule

`endif