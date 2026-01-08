`ifndef ADD_Q_V
`define ADD_Q_V

module add_Q #(
    parameter WIDTH = 32,
    parameter FBITS = 27
) (
    input  signed [WIDTH-1:0] a,
    input  signed [WIDTH-1:0] b,
    output signed [WIDTH-1:0] y
);
    wire signed [WIDTH:0] raw_y;
    assign raw_y = a + b;
    assign y = raw_y[WIDTH - 1 : 0];
endmodule

`endif