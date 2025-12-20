`ifndef SIGMOID
`define SIGMOID

module sigmoid #(
    parameter WIDTH = 32
) (
    input wire signed [WIDTH-1:0] x,
    output reg signed [WIDTH-1:0] y
);
    // Konstanta dalam format Q8.24
    localparam signed [WIDTH-1:0] ONE           = 32'h01000000; // 1.0
    localparam signed [WIDTH-1:0] HALF          = 32'h00800000; // 0.5
    localparam signed [WIDTH-1:0] CONST_0_625   = 32'h00A00000; // 0.625
    localparam signed [WIDTH-1:0] CONST_0_84375 = 32'h00D80000; // 0.84375
    
    // Thresholds (Batas Segmen) dalam Q8.24
    localparam signed [WIDTH-1:0] THR_1         = 32'h01000000; // 1.0
    localparam signed [WIDTH-1:0] THR_2         = 32'h02600000; // 2.375
    localparam signed [WIDTH-1:0] THR_3         = 32'h05000000; // 5.0

    reg [30:0] abs_x;
    reg [31:0] val;

    always @(*) begin
        // 1. Ambil Nilai Absolut
        if (x[31]) 
            abs_x = -x[30:0];
        else
            abs_x = x[30:0];

        // 2. Logika PWL (Sisi Positif)
        if (abs_x < THR_1) begin
            // y = 0.25x + 0.5  => (x >> 2) + 0.5
            val = (abs_x >> 2) + HALF;
        end 
        else if (abs_x < THR_2) begin
            // y = 0.125x + 0.625 => (x >> 3) + 0.625
            val = (abs_x >> 3) + CONST_0_625;
        end 
        else if (abs_x < THR_3) begin
            // y = 0.03125x + 0.84375 => (x >> 5) + 0.84375
            val = (abs_x >> 5) + CONST_0_84375;
        end 
        else begin
            // Saturasi
            val = ONE;
        end

        // 3. Terapkan Simetri: if x < 0 then y = 1 - val else y = val
        if (x[31])
            y = ONE - val;
        else
            y = val;
    end
endmodule

`endif 