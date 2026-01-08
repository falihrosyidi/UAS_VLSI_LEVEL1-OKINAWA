`ifndef NEURON_A
`define NEURON_A

`include "Util/tanh.v"
`include "Util/mult_Q.v"
`include "Util/register.v"

module neuron_a #(
    parameter WIDTH = 32
) (
    input signed [WIDTH-1:0] a_1,
    input signed [WIDTH-1:0] a_2,
    input signed [WIDTH-1:0] a_3,
    input signed [WIDTH-1:0] w_1,
    input signed [WIDTH-1:0] w_2,
    input signed [WIDTH-1:0] w_3,
    input signed [WIDTH-1:0] b,
    input clock, enable , reset , 
    output signed [WIDTH-1:0] y
);
    // LOCAL SIGNAL
    wire signed [WIDTH-1:0] out_In [0:2];
    wire signed [WIDTH-1:0] out_Reg[0:4];
    wire signed [WIDTH-1:0] pre_activation, out;

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

    //Register Perkalian 0 
    register #(.WIDTH(32))reg_1(
     .clk(clock),
     .en(enable),
     .rst(reset),
     .in(out_In[0]),
     .out(out_Reg[0])
    );

    //Register Perkalian 1 
    register #(.WIDTH(32))reg_2(
     .clk(clock),
     .en(enable),
     .rst(reset),
     .in(out_In[1]),
     .out(out_Reg[1])
    );

    //Register Perkalian 2 
    register #(.WIDTH(32))reg_3(
     .clk(clock),
     .en(enable),
     .rst(reset),
     .in(out_In[2]),
     .out(out_Reg[2])
    );

    //Register Bias 
    register #(.WIDTH(32))reg_4(
     .clk(clock),
     .en(enable),
     .rst(reset),
     .in(b),
     .out(out_Reg[3])
    );

    // ADD ALL
    assign pre_activation = out_Reg[0] + out_Reg[1] + out_Reg[2] + out_Reg[3];

     //Register Hasil Total Penjumlahan 
    register #(.WIDTH(32))reg_5(
     .clk(clock),
     .en(enable),
     .rst(reset),
     .in(pre_activation),
     .out(out_Reg[4])
    );

    // TANH <= ACTIVATE FUNCTION
    tanh activate_func (
        .a(out_Reg[4]),
        .y(out)
    );

    assign y = out;
endmodule

`endif