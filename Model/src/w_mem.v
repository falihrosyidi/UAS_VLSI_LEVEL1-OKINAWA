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
    assign g0_l2[0][0] = 32'hFFFF136B; assign g0_l2[0][1] = 32'h0003B16C;
    assign g0_l2[1][0] = 32'h0011018B; assign g0_l2[1][1] = 32'h0003A141;
    assign g0_l2[2][0] = 32'hFFCD02A7; assign g0_l2[2][1] = 32'hFFE2AB07;
    assign wg2_0 = {g0_l2[2][1], g0_l2[2][0], g0_l2[1][1], g0_l2[1][0], g0_l2[0][1], g0_l2[0][0]};

    // WG3 - Choice 0
    wire signed [WIDTH-1:0] g0_l3 [8:0][2:0];
    assign g0_l3[0][0]=32'h00A48E44; assign g0_l3[0][1]=32'h004EF36E; assign g0_l3[0][2]=32'h0022E4D2;
    assign g0_l3[1][0]=32'h00C1262B; assign g0_l3[1][1]=32'h005406F8; assign g0_l3[1][2]=32'h002FF424;
    assign g0_l3[2][0]=32'h00E854FD; assign g0_l3[2][1]=32'h006E334D; assign g0_l3[2][2]=32'h00272295;
    assign g0_l3[3][0]=32'h00EDF458; assign g0_l3[3][1]=32'h007302EE; assign g0_l3[3][2]=32'h000F7B18;
    assign g0_l3[4][0]=32'hFF19519A; assign g0_l3[4][1]=32'hFFC7C0B0; assign g0_l3[4][2]=32'hFFFEE823;
    assign g0_l3[5][0]=32'h01015B70; assign g0_l3[5][1]=32'h006460D1; assign g0_l3[5][2]=32'h000431D0;
    assign g0_l3[6][0]=32'h00D41A06; assign g0_l3[6][1]=32'h003D0464; assign g0_l3[6][2]=32'h002C355C;
    assign g0_l3[7][0]=32'h00C7D339; assign g0_l3[7][1]=32'h006B3EFC; assign g0_l3[7][2]=32'hFFFDB8B6;
    assign g0_l3[8][0]=32'h00C21C3D; assign g0_l3[8][1]=32'h007A1E0E; assign g0_l3[8][2]=32'hFFFFC4F4;
    assign wg3_0 = {g0_l3[8][2], g0_l3[8][1], g0_l3[8][0], g0_l3[7][2], g0_l3[7][1], g0_l3[7][0], 
                    g0_l3[6][2], g0_l3[6][1], g0_l3[6][0], g0_l3[5][2], g0_l3[5][1], g0_l3[5][0],
                    g0_l3[4][2], g0_l3[4][1], g0_l3[4][0], g0_l3[3][2], g0_l3[3][1], g0_l3[3][0],
                    g0_l3[2][2], g0_l3[2][1], g0_l3[2][0], g0_l3[1][2], g0_l3[1][1], g0_l3[1][0],
                    g0_l3[0][2], g0_l3[0][1], g0_l3[0][0]};

    // WD2 - Choice 0
    wire signed [WIDTH-1:0] d0_l2 [2:0][8:0];
    assign d0_l2[0][0]=32'hFFD27D37; assign d0_l2[0][1]=32'hFFCC5E1D; assign d0_l2[0][2]=32'hFFA019D2; assign d0_l2[0][3]=32'hFFB55620; assign d0_l2[0][4]=32'h00514D23; assign d0_l2[0][5]=32'hFFB6BAA0; assign d0_l2[0][6]=32'hFFBAEEA1; assign d0_l2[0][7]=32'hFFA8AA59; assign d0_l2[0][8]=32'hFFC8F99D;
    assign d0_l2[1][0]=32'hFFA86CA1; assign d0_l2[1][1]=32'hFFC71FA2; assign d0_l2[1][2]=32'hFFDE1B7D; assign d0_l2[1][3]=32'hFFD2040E; assign d0_l2[1][4]=32'h00313C5D; assign d0_l2[1][5]=32'hFFD8DB02; assign d0_l2[1][6]=32'hFFB3544D; assign d0_l2[1][7]=32'hFFED1B04; assign d0_l2[1][8]=32'hFFD11139;
    assign d0_l2[2][0]=32'h0035798E; assign d0_l2[2][1]=32'h0045D446; assign d0_l2[2][2]=32'h0017F38F; assign d0_l2[2][3]=32'h00185A48; assign d0_l2[2][4]=32'hFFE1F21C; assign d0_l2[2][5]=32'h00221C2B; assign d0_l2[2][6]=32'h000BF9FD; assign d0_l2[2][7]=32'h001DECCB; assign d0_l2[2][8]=32'h0041FB6E;
    assign wd2_0 = {d0_l2[2][8], d0_l2[2][7], d0_l2[2][6], d0_l2[2][5], d0_l2[2][4], d0_l2[2][3], d0_l2[2][2], d0_l2[2][1], d0_l2[2][0],
                    d0_l2[1][8], d0_l2[1][7], d0_l2[1][6], d0_l2[1][5], d0_l2[1][4], d0_l2[1][3], d0_l2[1][2], d0_l2[1][1], d0_l2[1][0],
                    d0_l2[0][8], d0_l2[0][7], d0_l2[0][6], d0_l2[0][5], d0_l2[0][4], d0_l2[0][3], d0_l2[0][2], d0_l2[0][1], d0_l2[0][0]};

    // WD3 - Choice 0
    assign wd3_0 = {32'h01537752, 32'hFE2AF3B2, 32'hFD5761CC};

    // ========================================================
    // DATA SET 1 (choice == 1)
    // ========================================================

    // WG2 - Choice 1
    wire signed [WIDTH-1:0] g1_l2 [2:0][1:0];
    assign g1_l2[0][0] = 32'h00031B23; assign g1_l2[0][1] = 32'h000B1F2D;
    assign g1_l2[1][0] = 32'h0006698C; assign g1_l2[1][1] = 32'hFFF75574;
    assign g1_l2[2][0] = 32'hFFF58F6B; assign g1_l2[2][1] = 32'hFFF7F06B;
    assign wg2_1 = {g1_l2[2][1], g1_l2[2][0], g1_l2[1][1], g1_l2[1][0], g1_l2[0][1], g1_l2[0][0]};

    // WG3 - Choice 1
    wire signed [WIDTH-1:0] g1_l3 [8:0][2:0];
    assign g1_l3[0][0]=32'hFFD8A3B2; assign g1_l3[0][1]=32'hFF8B0692; assign g1_l3[0][2]=32'h0080057B;
    assign g1_l3[1][0]=32'h00276D3B; assign g1_l3[1][1]=32'h0084AA00; assign g1_l3[1][2]=32'hFF8E9C68;
    assign g1_l3[2][0]=32'h003B3597; assign g1_l3[2][1]=32'hFF9EB60C; assign g1_l3[2][2]=32'h009F19E5;
    assign g1_l3[3][0]=32'h00608560; assign g1_l3[3][1]=32'h009453C9; assign g1_l3[3][2]=32'hFF84E07C;
    assign g1_l3[4][0]=32'hFFFA398F; assign g1_l3[4][1]=32'h00A091A4; assign g1_l3[4][2]=32'hFF86FA74;
    assign g1_l3[5][0]=32'h00676C25; assign g1_l3[5][1]=32'h007E69C1; assign g1_l3[5][2]=32'hFF7B9E2B;
    assign g1_l3[6][0]=32'hFFF75647; assign g1_l3[6][1]=32'hFF6F2E23; assign g1_l3[6][2]=32'h008BFA91;
    assign g1_l3[7][0]=32'h0019827C; assign g1_l3[7][1]=32'h0082F05D; assign g1_l3[7][2]=32'hFF6E941E;
    assign g1_l3[8][0]=32'hFFF0F9B3; assign g1_l3[8][1]=32'hFF99684C; assign g1_l3[8][2]=32'h007A5F49;
    assign wg3_1 = {g1_l3[8][2], g1_l3[8][1], g1_l3[8][0], g1_l3[7][2], g1_l3[7][1], g1_l3[7][0], 
                    g1_l3[6][2], g1_l3[6][1], g1_l3[6][0], g1_l3[5][2], g1_l3[5][1], g1_l3[5][0],
                    g1_l3[4][2], g1_l3[4][1], g1_l3[4][0], g1_l3[3][2], g1_l3[3][1], g1_l3[3][0],
                    g1_l3[2][2], g1_l3[2][1], g1_l3[2][0], g1_l3[1][2], g1_l3[1][1], g1_l3[1][0],
                    g1_l3[0][2], g1_l3[0][1], g1_l3[0][0]};

    // WD2 - Choice 1
    wire signed [WIDTH-1:0] d1_l2 [2:0][8:0];
    assign d1_l2[0][0]=32'hFFE5176F; assign d1_l2[0][1]=32'h002ACDB6; assign d1_l2[0][2]=32'hFFB96EA0; assign d1_l2[0][3]=32'h001F624C; assign d1_l2[0][4]=32'h001D28C4; assign d1_l2[0][5]=32'h002C605D; assign d1_l2[0][6]=32'hFFEEF697; assign d1_l2[0][7]=32'h001107FD; assign d1_l2[0][8]=32'hFFEB1EA0;
    assign d1_l2[1][0]=32'hFF9AE543; assign d1_l2[1][1]=32'h00544062; assign d1_l2[1][2]=32'hFFA89D42; assign d1_l2[1][3]=32'h004F28B0; assign d1_l2[1][4]=32'h0056B7D5; assign d1_l2[1][5]=32'h00516F71; assign d1_l2[1][6]=32'hFFA1517F; assign d1_l2[1][7]=32'h005F014E; assign d1_l2[1][8]=32'hFF9CED09;
    assign d1_l2[2][0]=32'h002979CF; assign d1_l2[2][1]=32'h001DF270; assign d1_l2[2][2]=32'hFFFFEFBD; assign d1_l2[2][3]=32'hFFE4FD91; assign d1_l2[2][4]=32'h000AF59C; assign d1_l2[2][5]=32'hFFE51CAD; assign d1_l2[2][6]=32'hFFE87560; assign d1_l2[2][7]=32'hFFE76A23; assign d1_l2[2][8]=32'h0021AEEA;
    assign wd2_1 = {d1_l2[2][8], d1_l2[2][7], d1_l2[2][6], d1_l2[2][5], d1_l2[2][4], d1_l2[2][3], d1_l2[2][2], d1_l2[2][1], d1_l2[2][0],
                    d1_l2[1][8], d1_l2[1][7], d1_l2[1][6], d1_l2[1][5], d1_l2[1][4], d1_l2[1][3], d1_l2[1][2], d1_l2[1][1], d1_l2[1][0],
                    d1_l2[0][8], d1_l2[0][7], d1_l2[0][6], d1_l2[0][5], d1_l2[0][4], d1_l2[0][3], d1_l2[0][2], d1_l2[0][1], d1_l2[0][0]};

    // WD3 - Choice 1
    assign wd3_1 = {32'hFFE0CB20, 32'h03811853, 32'h012918AC};

    // ========================================================
    // FINAL OUTPUT SELECTION (MUX)
    // ========================================================
    assign wg2 = choice[0] ? wg2_1 : wg2_0;
    assign wg3 = choice[1] ? wg3_1 : wg3_0;
    assign wd2 = choice[2] ? wd2_1 : wd2_0;
    assign wd3 = choice[3] ? wd3_1 : wd3_0;

endmodule

`endif