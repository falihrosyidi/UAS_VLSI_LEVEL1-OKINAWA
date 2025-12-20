`ifndef GENERATOR
`define GENERATOR

`include "neuron_o.v"
`include "neuron_a.v"

module generator #(
    parameter WIDTH = 32,
    parameter N_INPUT = 2,
    parameter N_NEURON_L2 = 3,
    parameter N_NEURON_L3 = 9
) (
    input signed [WIDTH-1:0] a_1,
    input signed [WIDTH-1:0] a_2,
    input signed [N_INPUT*N_NEURON_L2*WIDTH-1:0] w_L2,
    input signed [N_NEURON_L2*N_NEURON_L3*WIDTH-1:0] w_L3,
    input signed [N_NEURON_L2*WIDTH-1:0] b_L2,
    input signed [N_NEURON_L3*WIDTH-1:0] b_L3,
    output signed [WIDTH-1:0] y_1x1,
    output signed [WIDTH-1:0] y_1x2,
    output signed [WIDTH-1:0] y_1x3,
    output signed [WIDTH-1:0] y_2x1,
    output signed [WIDTH-1:0] y_2x2,
    output signed [WIDTH-1:0] y_2x3,
    output signed [WIDTH-1:0] y_3x1,
    output signed [WIDTH-1:0] y_3x2,
    output signed [WIDTH-1:0] y_3x3
);
// LAYER 2
    // LOCAL SIGNAL
    wire signed [WIDTH-1:0] out_L2 [N_NEURON_L2-1:0];

    genvar i;
    generate
        for (i=0; i<N_NEURON_L2; i=i+1) begin
            neuron_o NEURON_L2 (
                .a_1(a_1), .a_2(a_2),
                .w_1(w_L2[(N_INPUT*i+1)*WIDTH-1 : N_INPUT*i*WIDTH]), 
                .w_2(w_L2[(N_INPUT*i+2)*WIDTH-1 : (N_INPUT*i+1)*WIDTH]),
                .b(b_L2[(i+1)*WIDTH-1 : i*WIDTH]),
                .y(out_L2[i])
            );
        end
    endgenerate

// LAYER 3
    // LOCAL SIGNAL
    wire signed [WIDTH-1:0] out_L3 [N_NEURON_L3-1:0];

    genvar j;
    generate
        for (j=0; j<N_NEURON_L3; j=j+1) begin
            neuron_a NEURON_L3 (
                .a_1(out_L2[0]), .a_2(out_L2[1]), .a_3(out_L2[2]),
                .w_1(w_L3[(N_NEURON_L2*j+1)*WIDTH-1 : N_NEURON_L2*j*WIDTH]),
                .w_2(w_L3[(N_NEURON_L2*j+2)*WIDTH-1 : (N_NEURON_L2*j+1)*WIDTH]),                
                .w_3(w_L3[(N_NEURON_L2*j+3)*WIDTH-1 : (N_NEURON_L2*j+2)*WIDTH]),                
                .b(b_L3[(j+1)*WIDTH-1 : j*WIDTH]),
                .y(out_L3[j])                
            );
        end
    endgenerate

// CONNECT OUTPUT WITH OUT LAYER 3
    assign y_1x1 = out_L3[0];
    assign y_1x2 = out_L3[1];
    assign y_1x3 = out_L3[2];
    assign y_2x1 = out_L3[3];
    assign y_2x2 = out_L3[4];
    assign y_2x3 = out_L3[5];
    assign y_3x1 = out_L3[6];
    assign y_3x2 = out_L3[7];
    assign y_3x3 = out_L3[8];

endmodule

`endif