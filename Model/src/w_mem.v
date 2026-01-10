`ifndef W_MEM
`define W_MEM

module w_mem #(
    parameter WIDTH = 32,
    parameter N_INPUT = 2,
    parameter N_G_L2 = 3,
    parameter N_G_L3 = 9,
    parameter N_D_L2 = 3,
    parameter N_D_L3 = 1
) (
    input [3:0] choice,
    output [N_INPUT*N_G_L2*WIDTH-1:0] wg2,
    output [N_G_L2*N_G_L3*WIDTH-1:0] wg3,
    output [N_G_L3*N_D_L2*WIDTH-1:0] wd2,
    output [N_D_L2*N_D_L3*WIDTH-1:0] wd3
);

    // --- INTERNAL WIRES ---
    wire [N_INPUT*N_G_L2*WIDTH-1:0] wg2_0, wg2_1;
    wire [N_G_L2*N_G_L3*WIDTH-1:0] wg3_0, wg3_1;
    wire [N_G_L3*N_D_L2*WIDTH-1:0] wd2_0, wd2_1;
    wire [N_D_L2*N_D_L3*WIDTH-1:0] wd3_0, wd3_1;

    // ========================================================
    // DATA SET 0 (choice == 0)
    // ========================================================
    
    // WG2 - Choice 0
    wire signed [WIDTH-1:0] g0_l2 [2:0][1:0];
    assign g0_l2[0][0] = 32'hFFFF1337; assign g0_l2[0][1] = 32'h0003B169;
    assign g0_l2[1][0] = 32'h0011008F; assign g0_l2[1][1] = 32'h0003A13E;
    assign g0_l2[2][0] = 32'hFFCCFC5C; assign g0_l2[2][1] = 32'hFFE2AD20;
    assign wg2_0 = {g0_l2[2][1], g0_l2[2][0], g0_l2[1][1], g0_l2[1][0], g0_l2[0][1], g0_l2[0][0]};

    // WG3 - Choice 0
    wire signed [WIDTH-1:0] g0_l3 [8:0][2:0];
    assign g0_l3[0][0]=32'h00A48E60; assign g0_l3[0][1]=32'h004EE8B7; assign g0_l3[0][2]=32'h0022E4B6;
    assign g0_l3[1][0]=32'h00C125C5; assign g0_l3[1][1]=32'h005407FC; assign g0_l3[1][2]=32'h002FF250;
    assign g0_l3[2][0]=32'h00E8551F; assign g0_l3[2][1]=32'h006E32DF; assign g0_l3[2][2]=32'h0027230D;
    assign g0_l3[3][0]=32'h00EDF470; assign g0_l3[3][1]=32'h0073039C; assign g0_l3[3][2]=32'h000F7B9E;
    assign g0_l3[4][0]=32'hFF195298; assign g0_l3[4][1]=32'hFFC7C15B; assign g0_l3[4][2]=32'hFFEF8040;
    assign g0_l3[5][0]=32'h01015BDF; assign g0_l3[5][1]=32'h00646145; assign g0_l3[5][2]=32'h000431B4;
    assign g0_l3[6][0]=32'h00D41B22; assign g0_l3[6][1]=32'h003D0432; assign g0_l3[6][2]=32'h002C3587;
    assign g0_l3[7][0]=32'h00C7D3B9; assign g0_l3[7][1]=32'h006B3E87; assign g0_l3[7][2]=32'hFFFD96F5;
    assign g0_l3[8][0]=32'h00C21CDB; assign g0_l3[8][1]=32'h007A1D7C; assign g0_l3[8][2]=32'hFFFEC42F;
    assign wg3_0 = {g0_l3[8][2], g0_l3[8][1], g0_l3[8][0], g0_l3[7][2], g0_l3[7][1], g0_l3[7][0], 
                    g0_l3[6][2], g0_l3[6][1], g0_l3[6][0], g0_l3[5][2], g0_l3[5][1], g0_l3[5][0],
                    g0_l3[4][2], g0_l3[4][1], g0_l3[4][0], g0_l3[3][2], g0_l3[3][1], g0_l3[3][0],
                    g0_l3[2][2], g0_l3[2][1], g0_l3[2][0], g0_l3[1][2], g0_l3[1][1], g0_l3[1][0],
                    g0_l3[0][2], g0_l3[0][1], g0_l3[0][0]};

    // WD2 - Choice 0
    wire signed [WIDTH-1:0] d0_l2 [2:0][8:0];
    assign d0_l2[0][0]=32'hFFD27C89; assign d0_l2[0][1]=32'hFFCC5DD9; assign d0_l2[0][2]=32'hFF9FB305; assign d0_l2[0][3]=32'hFFB55605; assign d0_l2[0][4]=32'h00514D79; assign d0_l2[0][5]=32'hFFB6BB88; assign d0_l2[0][6]=32'hFFBACC69; assign d0_l2[0][7]=32'hFFA8A90A; assign d0_l2[0][8]=32'hFFC8FA23;
    assign d0_l2[1][0]=32'hFFA86C59; assign d0_l2[1][1]=32'hFFC71F2D; assign d0_l2[1][2]=32'hFFDE1A97; assign d0_l2[1][3]=32'hFFD2036E; assign d0_l2[1][4]=32'h00313C80; assign d0_l2[1][5]=32'hFFD8DA61; assign d0_l2[1][6]=32'hFFB354D2; assign d0_l2[1][7]=32'hFFED1AF9; assign d0_l2[1][8]=32'hFFD11093;
    assign d0_l2[2][0]=32'h00357A66; assign d0_l2[2][1]=32'h0045D529; assign d0_l2[2][2]=32'h0017F558; assign d0_l2[2][3]=32'h00185AAB; assign d0_l2[2][4]=32'hFFE1F28F; assign d0_l2[2][5]=32'h00221BA0; assign d0_l2[2][6]=32'h000BFCA2; assign d0_l2[2][7]=32'h001DEA80; assign d0_l2[2][8]=32'h0041FC2B;
    assign wd2_0 = {d0_l2[2][8], d0_l2[2][7], d0_l2[2][6], d0_l2[2][5], d0_l2[2][4], d0_l2[2][3], d0_l2[2][2], d0_l2[2][1], d0_l2[2][0],
                    d0_l2[1][8], d0_l2[1][7], d0_l2[1][6], d0_l2[1][5], d0_l2[1][4], d0_l2[1][3], d0_l2[1][2], d0_l2[1][1], d0_l2[1][0],
                    d0_l2[0][8], d0_l2[0][7], d0_l2[0][6], d0_l2[0][5], d0_l2[0][4], d0_l2[0][3], d0_l2[0][2], d0_l2[0][1], d0_l2[0][0]};

    // WD3 - Choice 0
    assign wd3_0 = {32'h015376DF, 32'hFE2AFC21, 32'hFD577081};

    // ========================================================
    // DATA SET 1 (choice == 1)
    // ========================================================

    // WG2 - Choice 1
    wire signed [WIDTH-1:0] g1_l2 [2:0][1:0];
    assign g1_l2[0][0] = 32'h00031B20; assign g1_l2[0][1] = 32'h000B1F2B;
    assign g1_l2[1][0] = 32'h00066991; assign g1_l2[1][1] = 32'hFFFF7596;
    assign g1_l2[2][0] = 32'hFFF58EEF; assign g1_l2[2][1] = 32'hFFF7F0E9;
    assign wg2_1 = {g1_l2[2][1], g1_l2[2][0], g1_l2[1][1], g1_l2[1][0], g1_l2[0][1], g1_l2[0][0]};

    // WG3 - Choice 1
    wire signed [WIDTH-1:0] g1_l3 [8:0][2:0];
    assign g1_l3[0][0]=32'hFFD8A468; assign g1_l3[0][1]=32'hFF8B0939; assign g1_l3[0][2]=32'h0080057C;
    assign g1_l3[1][0]=32'h00276CBE; assign g1_l3[1][1]=32'h0084AA0D; assign g1_l3[1][2]=32'hFF8DF7FE;
    assign g1_l3[2][0]=32'h003B3552; assign g1_l3[2][1]=32'hFF9EC001; assign g1_l3[2][2]=32'h009F1DD0;
    assign g1_l3[3][0]=32'h0060857C; assign g1_l3[3][1]=32'h00945439; assign g1_l3[3][2]=32'hFF84DF8D;
    assign g1_l3[4][0]=32'hFFFA371B; assign g1_l3[4][1]=32'h00A0914C; assign g1_l3[4][2]=32'hFF86F833;
    assign g1_l3[5][0]=32'h00676C3E; assign g1_l3[5][1]=32'h007E69DA; assign g1_l3[5][2]=32'hFF7BA2C3;
    assign g1_l3[6][0]=32'hFFF75605; assign g1_l3[6][1]=32'hFF6F7B85; assign g1_l3[6][2]=32'h008BF826;
    assign g1_l3[7][0]=32'h00198217; assign g1_l3[7][1]=32'h0082EDA4; assign g1_l3[7][2]=32'hFF6E93CE;
    assign g1_l3[8][0]=32'hFFF0EC5F; assign g1_l3[8][1]=32'hFF996709; assign g1_l3[8][2]=32'h007A5F7B;
    assign wg3_1 = {g1_l3[8][2], g1_l3[8][1], g1_l3[8][0], g1_l3[7][2], g1_l3[7][1], g1_l3[7][0], 
                    g1_l3[6][2], g1_l3[6][1], g1_l3[6][0], g1_l3[5][2], g1_l3[5][1], g1_l3[5][0],
                    g1_l3[4][2], g1_l3[4][1], g1_l3[4][0], g1_l3[3][2], g1_l3[3][1], g1_l3[3][0],
                    g1_l3[2][2], g1_l3[2][1], g1_l3[2][0], g1_l3[1][2], g1_l3[1][1], g1_l3[1][0],
                    g1_l3[0][2], g1_l3[0][1], g1_l3[0][0]};

    // WD2 - Choice 1
    wire signed [WIDTH-1:0] d1_l2 [2:0][8:0];
    assign d1_l2[0][0]=32'hFFE5178C; assign d1_l2[0][1]=32'h002ACB79; assign d1_l2[0][2]=32'hFFB96ECB; assign d1_l2[0][3]=32'h001F634E; assign d1_l2[0][4]=32'h001D28AA; assign d1_l2[0][5]=32'h002C5FEA; assign d1_l2[0][6]=32'hFFEDF254; assign d1_l2[0][7]=32'h0011072F; assign d1_l2[0][8]=32'hFFEB1E02;
    assign d1_l2[1][0]=32'hFF9AEABE; assign d1_l2[1][1]=32'h005440AF; assign d1_l2[1][2]=32'hFFA89D14; assign d1_l2[1][3]=32'h004F2882; assign d1_l2[1][4]=32'h0056B7E0; assign d1_l2[1][5]=32'h00516F24; assign d1_l2[1][6]=32'hFFA15139; assign d1_l2[1][7]=32'h005F00DF; assign d1_l2[1][8]=32'hFF9CF80C;
    assign d1_l2[2][0]=32'h002979E8; assign d1_l2[2][1]=32'h001DEE50; assign d1_l2[2][2]=32'hFFFEF9A6; assign d1_l2[2][3]=32'hFFE4FD36; assign d1_l2[2][4]=32'h000AF499; assign d1_l2[2][5]=32'hFFE51CBA; assign d1_l2[2][6]=32'hFFE8754C; assign d1_l2[2][7]=32'hFFE76A07; assign d1_l2[2][8]=32'h0021AE47;
    assign wd2_1 = {d1_l2[2][8], d1_l2[2][7], d1_l2[2][6], d1_l2[2][5], d1_l2[2][4], d1_l2[2][3], d1_l2[2][2], d1_l2[2][1], d1_l2[2][0],
                    d1_l2[1][8], d1_l2[1][7], d1_l2[1][6], d1_l2[1][5], d1_l2[1][4], d1_l2[1][3], d1_l2[1][2], d1_l2[1][1], d1_l2[1][0],
                    d1_l2[0][8], d1_l2[0][7], d1_l2[0][6], d1_l2[0][5], d1_l2[0][4], d1_l2[0][3], d1_l2[0][2], d1_l2[0][1], d1_l2[0][0]};

    // WD3 - Choice 1
    assign wd3_1 = {32'hFFE0CB4D, 32'h03811939, 32'h012919AA};

    // ========================================================
    // FINAL OUTPUT SELECTION (MUX)
    // ========================================================
    assign wg2 = choice[0] ? wg2_1 : wg2_0;
    assign wg3 = choice[1] ? wg3_1 : wg3_0;
    assign wd2 = choice[2] ? wd2_1 : wd2_0;
    assign wd3 = choice[3] ? wd3_1 : wd3_0;

endmodule

`endif