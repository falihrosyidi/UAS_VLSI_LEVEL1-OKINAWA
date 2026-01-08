`ifndef REGISTER
`define REGISTER

module register #(
    parameter WIDTH = 32
) (
    // Control Signal
    input  clk, en, rst,

    // Data Signal
    input  wire signed [WIDTH-1:0] in,
    output reg  signed [WIDTH-1:0] out
);
    always @(posedge clk) begin
        if (rst) begin
            out <= {WIDTH{1'b0}};
        end else if (en) begin
            out <= in;
        end
    end

endmodule
`endif 