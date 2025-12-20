`ifndef NEURON_C
`define NEURON_C

`include "Util/sigmoid.v"
`include "Util/mult_Q.v"

module neuron_c #(
    parameter WIDTH = 32
) (
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
    wire signed [WIDTH-1:0] out_In [0:2];
    wire signed [WIDTH-1:0] pre_activation, out;

    // Out @ INPUT
    // Out @ INPUT
    // Perkalian 0: a_1 * w_1
    mult_Q #(.WIDTH(32), .FBITS(24)) mult_0 (
    .a(a_1), 
    .b(w_1), 
    .y(out_In[0])  
    );

    // Perkalian 1: a_2 * w_2
    mult_Q #(.WIDTH(32), .FBITS(24)) mult_1 (
    .a(a_2), 
    .b(w_2), 
    .y(out_In[1])
    );

    // Perkalian 2: a_3 * w_3
    mult_Q #(.WIDTH(32), .FBITS(24)) mult_2 (
    .a(a_3), 
    .b(w_3), 
    .y(out_In[2])
    );

    // ADD ALL
    assign pre_activation = out_In[0] + out_In[1] + out_In[2] + b;

    // SIGMOID <= ACTIVATE FUNCTION
    sigmoid activate_func (
        .x(pre_activation),
        .y(out)
    );

    assign y = out;
endmodule

`endif