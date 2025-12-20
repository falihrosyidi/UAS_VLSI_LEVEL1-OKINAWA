`ifndef NEURON_O
`define NEURON_O

`include "Util/tanh.v"

module neuron_o #(
    parameter WIDTH = 32
) (
    input signed [WIDTH-1:0] a_1,
    input signed [WIDTH-1:0] a_2,
    input signed [WIDTH-1:0] w_1,
    input signed [WIDTH-1:0] w_2,
    input signed [WIDTH-1:0] b,
    output signed [WIDTH-1:0] y
);
    // LOCAL SIGNAL
    wire signed [WIDTH-1:0] [1:0] out_In;
    wire signed [WIDTH-1:0] pre_activation, out;

    // Out @ INPUT
    assign out_In[0] = a_1*w_1;
    assign out_In[1] = a_2*w_2;

    // ADD ALL
    assign pre_activation = out_In[0] + out_In[1] + b;

    // TANH <= ACTIVATE FUNCTION
    tanh activate_func (
        .a(pre_activation),
        .y(out)
    );

    assign y = out;
endmodule

`endif