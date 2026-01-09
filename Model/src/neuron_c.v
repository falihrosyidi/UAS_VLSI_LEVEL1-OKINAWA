`ifndef NEURON_C
`define NEURON_C

`include "Util/sigmoid.v"
`include "Util/mult_Q.v"
`include "Util/register.v"

module neuron_c #(
    parameter WIDTH = 32
) (
    // Control Signal
    input  clk, en, rst,

    // Data Signal
    input signed [WIDTH-1:0] a_1,
    input signed [WIDTH-1:0] a_2,
    input signed [WIDTH-1:0] a_3,
    input signed [WIDTH-1:0] w_1,
    input signed [WIDTH-1:0] w_2,
    input signed [WIDTH-1:0] w_3,
    input signed [WIDTH-1:0] b,
    output signed [WIDTH-1:0] y
);
    // LOCAL SIGNAL
    wire signed [WIDTH-1:0] out_mult [1:3];
    wire signed [WIDTH-1:0] pre_activation, out;

    // Perkalian 0: a_1 * w_1
    mult_Q #(.WIDTH(32), .FBITS(24)) mult_0 (
    .a(a_1), .b(w_1), .y(out_mult[1])  
    );

    // Perkalian 1: a_2 * w_2
    mult_Q #(.WIDTH(32), .FBITS(24)) mult_1 (
    .a(a_2), .b(w_2), .y(out_mult[2])
    );

    // Perkalian 2: a_3 * w_3
    mult_Q #(.WIDTH(32), .FBITS(24)) mult_2 (
    .a(a_3), .b(w_3), .y(out_mult[3])
    );

    // PIPELINE
    wire signed [WIDTH-1:0] out_mult_reg [1:3];

    genvar i;
    generate
        for (i = 1; i <= 3 ; i = i + 1) begin
            // PIPELINE OUT MULT
            register #(.WIDTH(WIDTH)) reg_mult (
                .clk(clk), .en(en), .rst(rst),
                .in(out_mult[i]), .out(out_mult_reg[i])
            );
        end
    endgenerate

    // ADD ALL
    assign pre_activation = out_mult_reg[1] + out_mult_reg[2] + out_mult_reg[3] + b;

    // PIPELINE
    wire signed [WIDTH-1:0] pre_activation_reg;

    register #(.WIDTH(WIDTH)) reg_pre_activation (
        .clk(clk), .en(en), .rst(rst),
        .in(pre_activation), .out(pre_activation_reg)
    );

    // SIGMOID <= ACTIVATE FUNCTION
    sigmoid activate_func (
        .clk(clk), .en(en), .rst(rst),
        .a(pre_activation_reg), .y(out)
    );

    assign y = out;
endmodule

`endif