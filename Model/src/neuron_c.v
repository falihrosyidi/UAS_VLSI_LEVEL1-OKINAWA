`ifndef NEURON_C
`define NEURON_C

`include "Util/tanh.v"

module neuron_c #(
    parameter WIDTH = 32
) (
    input signed [WIDTH-1:0] a_1,
    input signed [WIDTH-1:0] a_2,
    input signed [WIDTH-1:0] a_3,
    input signed [WIDTH-1:0] w_1,
    input signed [WIDTH-1:0] w_2,
    input signed [WIDTH-1:0] w_3,
    input signed [WIDTH-1:0] b_1,
    input signed [WIDTH-1:0] b_2,
    input signed [WIDTH-1:0] b_3,
    output signed [WIDTH-1:0] y
);
    // LOCAL SIGNAL
    wire signed [WIDTH-1:0] [2:0] out_In;
    wire signed [WIDTH-1:0] pre_activation, out;

    // Out @ INPUT
    assign out_In[0] = a_1*w_1+b_1;
    assign out_In[1] = a_1*w_1+b_1;
    assign out_In[2] = a_1*w_1+b_1;

    // ADD ALL
    assign pre_activation = out_In[0] + out_In[1] + out_In[2];

    // SIGMOID <= ACTIVATE FUNCTION
    sigmoid activate_func (
        .a(pre_activation),
        .y(out)
    );

    assign y = out;
endmodule

`endif