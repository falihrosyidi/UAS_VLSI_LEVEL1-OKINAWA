`ifndef DISCRIMINATOR
`define DISCRIMINATOR

`include "neuron_b.v"
`include "neuron_c.v"

module discriminator #(
    parameter WIDTH = 32,
    parameter N_INPUT = 9,
    parameter N_NEURON_L2 = 3,
    parameter N_NEURON_L3 = 1
) (
    input signed [WIDTH-1:0] a_1,
    input signed [WIDTH-1:0] a_2,
    input signed [WIDTH-1:0] a_3,
    input signed [WIDTH-1:0] a_4,
    input signed [WIDTH-1:0] a_5,
    input signed [WIDTH-1:0] a_6,
    input signed [WIDTH-1:0] a_7,
    input signed [WIDTH-1:0] a_8,
    input signed [WIDTH-1:0] a_9,
    input signed [N_INPUT*N_NEURON_L2*WIDTH-1:0] w_L2,
    input signed [N_NEURON_L2*N_NEURON_L3*WIDTH-1:0] w_L3,
    input signed [N_NEURON_L2*WIDTH-1:0] b_L2,
    input signed [N_NEURON_L3*WIDTH-1:0] b_L3,
    output signed [WIDTH-1:0] y
);
// LAYER 2
    // LOCAL SIGNAL
    wire signed [WIDTH-1:0] out_L2 [N_NEURON_L2-1:0];

    genvar i;
    generate
        for (i=0; i<N_NEURON_L2; i=i+1) begin
            neuron_b NEURON_L2 (
                .a_1(a_1), .a_2(a_2),
                .w_1(w_L2[(N_INPUT*i+1)*WIDTH-1 : N_INPUT*i*WIDTH]), 
                .w_2(w_L2[(N_INPUT*i+2)*WIDTH-1 : (N_INPUT*i+1)*WIDTH]),
                .w_3(w_L2[(N_INPUT*i+3)*WIDTH-1 : (N_INPUT*i+2)*WIDTH]),
                .w_4(w_L2[(N_INPUT*i+4)*WIDTH-1 : (N_INPUT*i+3)*WIDTH]),
                .w_5(w_L2[(N_INPUT*i+5)*WIDTH-1 : (N_INPUT*i+4)*WIDTH]),
                .w_6(w_L2[(N_INPUT*i+6)*WIDTH-1 : (N_INPUT*i+5)*WIDTH]),
                .w_7(w_L2[(N_INPUT*i+7)*WIDTH-1 : (N_INPUT*i+6)*WIDTH]),
                .w_8(w_L2[(N_INPUT*i+8)*WIDTH-1 : (N_INPUT*i+7)*WIDTH]),
                .w_9(w_L2[(N_INPUT*i+9)*WIDTH-1 : (N_INPUT*i+8)*WIDTH]),
                .b(b_L2[(i+1)*WIDTH-1 : i*WIDTH]),
                .y(out_L2[i])
            );
        end
    endgenerate

// LAYER 3
    // LOCAL SIGNAL
    wire signed [WIDTH-1:0] out_L3;

    neuron_c NEURON_L3 (
        .a_1(out_L2[0]), .a_2(out_L2[1]), .a_3(out_L2[2]),
        .w_1(w_L3[31: 0]),
        .w_2(w_L3[63:32]),                
        .w_3(w_L3[95:64]),                
        .b(b_L3),
        .y(out_L3)                
    );

// CONNECT OUTPUT WITH OUT LAYER 3
    assign y = out_L3;

endmodule

`endif