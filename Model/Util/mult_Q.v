module mult_Q #(
    parameter WIDTH = 32,
    parameter FBITS = 27
) (
    input  signed [WIDTH-1:0] a,
    input  signed [WIDTH-1:0] b,
    output signed [WIDTH-1:0] y
);
    wire signed [(2*WIDTH)-1:0] raw_y;
    assign raw_y = a * b;
    assign y = raw_y[FBITS + WIDTH - 1 : FBITS];
endmodule