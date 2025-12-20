`include "w_mem.v"
`include "b_mem.v"
`include "generator.v"
`include "discriminator.v"

module top_level #(
    parameter WIDTH = 32
) (
    input choice,
    input signed [WIDTH-1:0] in_1, in_2,
    output signed [WIDTH-1:0] out_discriminator,
    output signed [WIDTH-1:0] pixel_1x1,
    output signed [WIDTH-1:0] pixel_1x2,
    output signed [WIDTH-1:0] pixel_1x3,
    output signed [WIDTH-1:0] pixel_2x1,
    output signed [WIDTH-1:0] pixel_2x2,
    output signed [WIDTH-1:0] pixel_2x3,
    output signed [WIDTH-1:0] pixel_3x1,
    output signed [WIDTH-1:0] pixel_3x2,
    output signed [WIDTH-1:0] pixel_3x3
);
    localparam  N_INPUT = 2;
    localparam  N_G_L2 = 3;
    localparam  N_G_L3 = 9;
    localparam  N_D_L2 = 3;
    localparam  N_D_L3 = 1;

    // MEMORY
    wire [N_INPUT*N_G_L2*WIDTH-1:0] wg2;
    wire [N_G_L2*N_G_L3*WIDTH-1:0] wg3;
    wire [N_G_L3*N_D_L2*WIDTH-1:0] wd2;
    wire [N_D_L2*N_D_L3*WIDTH-1:0] wd3;
    w_mem WEIGH_MEMORY (
        .choice(choice), .wg2(wg2), .wg3(wg3), .wd2(wd2), .wd3(wd3)
    );

    wire [N_G_L2*WIDTH-1:0] bg2;
    wire [N_G_L3*WIDTH-1:0] bg3;
    wire [N_D_L2*WIDTH-1:0] bd2;
    wire [N_D_L3*WIDTH-1:0] bd3;
    b_mem BIAS_MEMORY (
        .choice(choice), .bg2(bg2), .bg3(bg3), .bd2(bd2), .bd3(bd3)
    );

    // GAN
    wire signed [WIDTH-1:0] y_1x1;
    wire signed [WIDTH-1:0] y_1x2;
    wire signed [WIDTH-1:0] y_1x3;
    wire signed [WIDTH-1:0] y_2x1;
    wire signed [WIDTH-1:0] y_2x2;
    wire signed [WIDTH-1:0] y_2x3;
    wire signed [WIDTH-1:0] y_3x1;
    wire signed [WIDTH-1:0] y_3x2;
    wire signed [WIDTH-1:0] y_3x3;
    generator GENERATOR (
        .a_1(in_1), .a_2(in_2), 
        .w_L2(wg2), .w_L3(wg3), .b_L2(bg2), .b_L3(bg3),
        .y_1x1(y_1x1), .y_1x2(y_1x2), .y_1x3(y_1x3),
        .y_2x1(y_2x1), .y_2x2(y_2x2), .y_2x3(y_2x3),
        .y_3x1(y_3x1), .y_3x2(y_3x2), .y_3x3(y_3x3)
    );

    wire signed [WIDTH-1:0] out_disc;
    discriminator DISCRIMINATOR (
        .a_1(y_1x1), .a_2(y_1x2), .a_3(y_1x3),
        .a_4(y_2x1), .a_5(y_2x2), .a_6(y_2x3),
        .a_7(y_3x1), .a_8(y_3x2), .a_9(y_3x3),
        .w_L2(wd2), .w_L3(wd3), .b_L2(bd2), .b_L3(bd3),
        .y(out_disc)
    );

    // OUTPUT
    assign out_discriminator = out_disc;
    assign pixel_1x1 = y_1x1;
    assign pixel_1x2 = y_1x2;
    assign pixel_1x3 = y_1x3;
    assign pixel_2x1 = y_2x1;
    assign pixel_2x2 = y_2x2;
    assign pixel_2x3 = y_2x3;
    assign pixel_3x1 = y_3x1;
    assign pixel_3x2 = y_3x2;
    assign pixel_3x3 = y_3x3;

endmodule