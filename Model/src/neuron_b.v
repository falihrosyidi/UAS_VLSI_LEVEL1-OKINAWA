`ifndef NEURON_B
`define NEURON_B

`include "Util/tanh.v"

module neuron_b #(
    parameter WIDTH = 32
) (
    input signed [WIDTH-1:0] a_1, a_2, a_3, a_4, a_5, a_6, a_7, a_8, a_9,
    input  signed [WIDTH-1:0] w_1, w_2, w_3, w_4, w_5, w_6, w_7, w_8, w_9,
    input signed [WIDTH-1:0] b,
    output signed [WIDTH-1:0] y
);  

    wire signed [WIDTH-1:0] a_arr [1:9];
    wire signed [WIDTH-1:0] w_arr [1:9];
    // Hasil Perkalian (a * w)
    wire signed [WIDTH-1:0] m  [1:9]; 
    wire signed [WIDTH-1:0]  m_1, m_2, m_3, m_4, m_5, m_6, m_7, m_8, m_9 ;
    // Hasil Penjumlahan (a* w) + b
    wire signed [WIDTH-1:0] s  [1:9];
    wire signed [WIDTH-1:0]  s_1, s_2, s_3, s_4, s_5, s_6, s_7, s_8, s_9 ;
    // Hasil penjumlahan 3 sum (1,2,3 ; 4,5,6 ; 7,8,9) 
    wire signed [WIDTH-1:0]  sum_123, sum_456 , sum_789 ;
    // Hasil penjumlahan 3 sum (123 , 456, 789)
    wire signed [WIDTH-1:0]  total_sum ;

    assign a_arr[1] = a_1; assign a_arr[2] = a_2; assign a_arr[3] = a_3;
    assign a_arr[4] = a_4; assign a_arr[5] = a_5; assign a_arr[6] = a_6;
    assign a_arr[7] = a_7; assign a_arr[8] = a_8; assign a_arr[9] = a_9;

    assign w_arr[1] = w_1; assign w_arr[2] = w_2; assign w_arr[3] = w_3;
    assign w_arr[4] = w_4; assign w_arr[5] = w_5; assign w_arr[6] = w_6;
    assign w_arr[7] = w_7; assign w_arr[8] = w_8; assign w_arr[9] = w_9;

    genvar i;
    generate
        for (i = 1; i <= 9 ; i = i + 1) begin
            assign m[i] = a_arr[i] * w_arr[i] ; 
        end
    endgenerate
    
    assign sum_123 = m[1] + m[2] + m[3] ;
    assign sum_456 = m[4] + m[5] + m[6] ;
    assign sum_789 = m[7] + m[8] + m[9] ;
    assign total_sum = sum_123 + sum_456 + sum_789 + b ;

    // TANH <= ACTIVATE FUNCTION
    tanh activate_func (
        .a(total_sum),
        .y(out)
    );
    wire signed [WIDTH-1:0] out;

    assign y = out;
endmodule

`endif