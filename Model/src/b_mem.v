`ifndef B_MEM
`define B_MEM

module b_mem #(
    parameter WIDTH = 32,
    parameter N_G_L2 = 3,
    parameter N_G_L3 = 9,
    parameter N_D_L2 = 3,
    parameter N_D_L3 = 1
) (
    input [3:0] choice,
    output [N_G_L2*WIDTH-1:0] bg2,
    output [N_G_L3*WIDTH-1:0] bg3,
    output [N_D_L2*WIDTH-1:0] bd2,
    output [N_D_L3*WIDTH-1:0] bd3
);

    // --- INTERNAL WIRES ---
    wire [N_G_L2*WIDTH-1:0] bg2_0, bg2_1;
    wire [N_G_L3*WIDTH-1:0] bg3_0, bg3_1;
    wire [N_D_L2*WIDTH-1:0] bd2_0, bd2_1;
    wire [N_D_L3*WIDTH-1:0] bd3_0, bd3_1;

    // ========================================================
    // DATA SET 0 (choice == 0)
    // ========================================================
    
    // Bias Generator Layer 2 (bg2) - Choice 0
    wire signed [WIDTH-1:0] b0_g_l2 [N_G_L2-1:0];
    assign b0_g_l2[0] = 32'h01A1B251; // 1.631627
    assign b0_g_l2[1] = 32'h00EF37E3; // 0.934426
    assign b0_g_l2[2] = 32'h0041432E; // 0.254929
    assign bg2_0 = {b0_g_l2[2], b0_g_l2[1], b0_g_l2[0]};

    // Bias Generator Layer 3 (bg3) - Choice 0
    wire signed [WIDTH-1:0] b0_g_l3 [N_G_L3-1:0];
    assign b0_g_l3[0] = 32'h0163E32C; // 1.390187
    assign b0_g_l3[1] = 32'h014AAB54; // 1.291887
    assign b0_g_l3[2] = 32'h010BC5C6; // 1.046107
    assign b0_g_l3[3] = 32'h0111295A; // 1.067029
    assign b0_g_l3[4] = 32'hFEB9FAAD; // -1.2728
    assign b0_g_l3[5] = 32'h01106A9F; // 1.064147
    assign b0_g_l3[6] = 32'h014D351F; // 1.301596
    assign b0_g_l3[7] = 32'h0146C65A; // 1.276455
    assign b0_g_l3[8] = 32'h01374BD8; // 1.216003
    assign bg3_0 = {b0_g_l3[8], b0_g_l3[7], b0_g_l3[6], b0_g_l3[5], b0_g_l3[4], b0_g_l3[3], b0_g_l3[2], b0_g_l3[1], b0_g_l3[0]};

    // Bias Discriminator Layer 2 (bd2) - Choice 0
    wire signed [WIDTH-1:0] b0_d_l2 [N_D_L2-1:0];
    assign b0_d_l2[0] = 32'h025346B1; // 2.325301
    assign b0_d_l2[1] = 32'h0195463D; // 1.583088
    assign b0_d_l2[2] = 32'hFEE8F371; // -1.0901
    assign bd2_0 = {b0_d_l2[2], b0_d_l2[1], b0_d_l2[0]};

    // Bias Discriminator Layer 3 (bd3) - Choice 0
    assign bd3_0 = 32'hFF0AB782; // -0.95783

    // ========================================================
    // DATA SET 1 (choice == 1)
    // ========================================================
    
    // Bias Generator Layer 2 (bg2) - Choice 1
    wire signed [WIDTH-1:0] b1_g_l2 [N_G_L2-1:0];
    assign b1_g_l2[0] = 32'h004FF5B6; // 0.312248
    assign b1_g_l2[1] = 32'h013211EC; // 1.19559
    assign b1_g_l2[2] = 32'hFEC6FD9C; // -1.2229
    assign bg2_1 = {b1_g_l2[2], b1_g_l2[1], b1_g_l2[0]};

    // Bias Generator Layer 3 (bg3) - Choice 1
    wire signed [WIDTH-1:0] b1_g_l3 [N_G_L3-1:0];
    assign b1_g_l3[0] = 32'hFE97BA14; // -1.40726
    assign b1_g_l3[1] = 32'h01777266; // 1.466492
    assign b1_g_l3[2] = 32'hFE7DF6F6; // -1.5057
    assign b1_g_l3[3] = 32'h014A62AC; // 1.290558
    assign b1_g_l3[4] = 32'h015EBA5B; // 1.369977
    assign b1_g_l3[5] = 32'h014F75DB; // 1.310394
    assign b1_g_l3[6] = 32'hFEADED29; // -1.32089
    assign b1_g_l3[7] = 32'h015452B8; // 1.329336
    assign b1_g_l3[8] = 32'hFE6E7E6F; // -1.56614
    assign bg3_1 = {b1_g_l3[8], b1_g_l3[7], b1_g_l3[6], b1_g_l3[5], b1_g_l3[4], b1_g_l3[3], b1_g_l3[2], b1_g_l3[1], b1_g_l3[0]};

    // Bias Discriminator Layer 2 (bd2) - Choice 1
    wire signed [WIDTH-1:0] b1_d_l2 [N_D_L2-1:0];
    assign b1_d_l2[0] = 32'hFF223F6F; // -0.86624
    assign b1_d_l2[1] = 32'hFCFA3A3D; // -3.0216
    assign b1_d_l2[2] = 32'h00060D6D; // 0.023642
    assign bd2_1 = {b1_d_l2[2], b1_d_l2[1], b1_d_l2[0]};

    // Bias Discriminator Layer 3 (bd3) - Choice 1
    assign bd3_1 = 32'hFF43FC67; // -0.73444

    // ========================================================
    // LOGIKA PEMILIH (MULTIPLEXER)
    // ========================================================
    assign bg2 = choice[0] ? bg2_1 : bg2_0;
    assign bg3 = choice[1] ? bg3_1 : bg3_0;
    assign bd2 = choice[2] ? bd2_1 : bd2_0;
    assign bd3 = choice[3] ? bd3_1 : bd3_0;

endmodule

`endif