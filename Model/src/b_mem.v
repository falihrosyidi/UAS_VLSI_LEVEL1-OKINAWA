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
    assign b0_g_l2[0] = 32'h01A1B252; // 1.631627202
    assign b0_g_l2[1] = 32'h00EF368B; // 0.93442601
    assign b0_g_l2[2] = 32'h00414304; // 0.254928827
    assign bg2_0 = {b0_g_l2[2], b0_g_l2[1], b0_g_l2[0]};

    // Bias Generator Layer 3 (bg3) - Choice 0
    wire signed [WIDTH-1:0] b0_g_l3 [N_G_L3-1:0];
    assign b0_g_l3[0] = 32'h0163E347; // 1.390186727
    assign b0_g_l3[1] = 32'h014AB91D; // 1.291887105
    assign b0_g_l3[2] = 32'h010BCDA6; // 1.046106696
    assign b0_g_l3[3] = 32'h011128D2; // 1.067029119
    assign b0_g_l3[4] = 32'hFEBA2999; // -1.27280277
    assign b0_g_l3[5] = 32'h01106BEB; // 1.064146698
    assign b0_g_l3[6] = 32'h014D3565; // 1.301595986
    assign b0_g_l3[7] = 32'h0146C5C1; // 1.276454985
    assign b0_g_l3[8] = 32'h01374BFC; // 1.21600318
    assign bg3_0 = {b0_g_l3[8], b0_g_l3[7], b0_g_l3[6], b0_g_l3[5], b0_g_l3[4], b0_g_l3[3], b0_g_l3[2], b0_g_l3[1], b0_g_l3[0]};

    // Bias Discriminator Layer 2 (bd2) - Choice 0
    wire signed [WIDTH-1:0] b0_d_l2 [N_D_L2-1:0];
    assign b0_d_l2[0] = 32'h025346EE; // 2.325301051
    assign b0_d_l2[1] = 32'h01954545; // 1.583088219
    assign b0_d_l2[2] = 32'hFEE8EF7B; // -1.090095818
    assign bd2_0 = {b0_d_l2[2], b0_d_l2[1], b0_d_l2[0]};

    // Bias Discriminator Layer 3 (bd3) - Choice 0
    assign bd3_0 = 32'hFF0ACBCD; // -0.957827747

    // ========================================================
    // DATA SET 1 (choice == 1)
    // ========================================================
    
    // Bias Generator Layer 2 (bg2) - Choice 1
    wire signed [WIDTH-1:0] b1_g_l2 [N_G_L2-1:0];
    assign b1_g_l2[0] = 32'h004FEF7D; // 0.312248051
    assign b1_g_l2[1] = 32'h01321232; // 1.195590138
    assign b1_g_l2[2] = 32'hFEC6EFD6; // -1.222902894
    assign bg2_1 = {b1_g_l2[2], b1_g_l2[1], b1_g_l2[0]};

    // Bias Generator Layer 3 (bg3) - Choice 1
    wire signed [WIDTH-1:0] b1_g_l3 [N_G_L3-1:0];
    assign b1_g_l3[0] = 32'hFE97BDF2; // -1.407257915
    assign b1_g_l3[1] = 32'h01776C06; // 1.466492057
    assign b1_g_l3[2] = 32'hFE7E8A8C; // -1.505698442
    assign b1_g_l3[3] = 32'h014A61FF; // 1.290557802
    assign b1_g_l3[4] = 32'h015EB6CC; // 1.369976759
    assign b1_g_l3[5] = 32'h014F75F3; // 1.310393512
    assign b1_g_l3[6] = 32'hFEADD9E2; // -1.320894122
    assign b1_g_l3[7] = 32'h01544F63; // 1.329336345
    assign b1_g_l3[8] = 32'hFE6F117B; // -1.566139519
    assign bg3_1 = {b1_g_l3[8], b1_g_l3[7], b1_g_l3[6], b1_g_l3[5], b1_g_l3[4], b1_g_l3[3], b1_g_l3[2], b1_g_l3[1], b1_g_l3[0]};

    // Bias Discriminator Layer 2 (bd2) - Choice 1
    wire signed [WIDTH-1:0] b1_d_l2 [N_D_L2-1:0];
    assign b1_d_l2[0] = 32'hFF223DCC; // -0.866244555
    assign b1_d_l2[1] = 32'hFCFA7869; // -3.021600187
    assign b1_d_l2[2] = 32'h00060D6F; // 0.02364248
    assign bd2_1 = {b1_d_l2[2], b1_d_l2[1], b1_d_l2[0]};

    // Bias Discriminator Layer 3 (bd3) - Choice 1
    assign bd3_1 = 32'hFF43FBB5; // -0.734440506

    // ========================================================
    // LOGIKA PEMILIH (MULTIPLEXER)
    // ========================================================
    assign bg2 = choice[0] ? bg2_1 : bg2_0;
    assign bg3 = choice[1] ? bg3_1 : bg3_0;
    assign bd2 = choice[2] ? bd2_1 : bd2_0;
    assign bd3 = choice[3] ? bd3_1 : bd3_0;

endmodule

`endif