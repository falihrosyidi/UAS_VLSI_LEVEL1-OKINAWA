`timescale 1ns / 1ps
`include "tanh.v"

module tanh_tb();

    // Parameter
    parameter WIDTH = 32;
    parameter FL = 24;
    real SCALE = 16777216.0; // 2^24

    // Inputs
    reg signed [WIDTH-1:0] a;
    
    // Outputs
    wire signed [WIDTH-1:0] y;

    // Instansiasi Unit Under Test (UUT)
    tanh #(
        .WIDTH(WIDTH),
        .FL(FL)
    ) uut (
        .a(a),
        .y(y)
    );

    // PERBAIKAN: Helper function untuk konversi fixed-point ke real
    function real fixed_to_real;
        input signed [WIDTH-1:0] fixed_val;
        begin
            // Konversi signed fixed-point ke real dengan benar
            if (fixed_val[WIDTH-1] == 1'b1) begin
                // Negatif: konversi two's complement
                fixed_to_real = -($signed(~fixed_val + 1'b1)) / SCALE;
            end else begin
                // Positif
                fixed_to_real = $signed(fixed_val) / SCALE;
            end
        end
    endfunction

    // PERBAIKAN: Helper function untuk konversi real ke fixed-point
    function signed [WIDTH-1:0] real_to_fixed;
        input real real_val;
        reg signed [WIDTH-1:0] temp;
        begin
            if (real_val < 0) begin
                // Negatif: hitung two's complement
                temp = $rtoi(-real_val * SCALE);
                real_to_fixed = ~temp + 1'b1;
            end else begin
                // Positif
                real_to_fixed = $rtoi(real_val * SCALE);
            end
        end
    endfunction

    // PERBAIKAN: Task untuk test dengan konversi yang benar
    task check_val(input real val);
        real output_real;
        begin
            a = real_to_fixed(val);  // Konversi benar untuk negatif!
            #10;
            
            output_real = fixed_to_real(y);  // Konversi output dengan benar
            
            $display("Input: %8.4f (Hex: %h) | Output: %8.4f (Hex: %h)", 
                      val, a, output_real, y);
        end
    endtask

    initial begin
        $display("==========================================================");
        $display("   UJI COBA MODUL TANH PWQ (FIXED-POINT Q8.24)");
        $display("==========================================================");

        // --- TEST CASE 1: Segmen 0 (0 <= x < 1) ---
        $display("\n--- Segmen 0 (Linier-ish) ---");
        check_val(0.0);
        check_val(0.25);
        check_val(0.5);
        check_val(0.75);

        // --- TEST CASE 2: Segmen 1 (1 <= x < 2) ---
        $display("\n--- Segmen 1 (Lengkungan) ---");
        check_val(1.0);
        check_val(1.5);

        // --- TEST CASE 3: Segmen 2 (2 <= x < 4) ---
        $display("\n--- Segmen 2 (Mendekati Jenuh) ---");
        check_val(2.5);
        check_val(3.5);

        // --- TEST CASE 4: Saturasi Positif (x >= 4) ---
        $display("\n--- Saturasi Positif ---");
        check_val(4.0);
        check_val(10.0);

        // --- TEST CASE 5: Uji Simetri Negatif ---
        $display("\n--- Uji Simetri Negatif ---");
        check_val(-0.5);
        check_val(-1.5);
        check_val(-5.0);

        // --- TEST CASE 6: Verifikasi dengan Expected dari MATLAB ---
        $display("\n--- Verifikasi dengan MATLAB Reference ---");
        check_val_with_expected(0.0,   32'h00000000);
        check_val_with_expected(0.5,   32'h00761727);
        check_val_with_expected(1.0,   32'h00C422BC);
        check_val_with_expected(1.5,   32'h00E7BFF4);
        check_val_with_expected(2.5,   32'h00FC27A2);
        check_val_with_expected(4.0,   32'h01000000);
        check_val_with_expected(-0.5,  32'hFF89E8D9);
        check_val_with_expected(-1.5,  32'hFF18400C);
        check_val_with_expected(-5.0,  32'hFF000000);

        $display("\n==========================================================");
        $display("            SIMULASI SELESAI");
        $display("==========================================================");
        $finish;
    end

    // TAMBAHAN: Task untuk verifikasi dengan expected value
    task check_val_with_expected(input real val, input signed [WIDTH-1:0] expected);
        real output_real;
        integer error;
        begin
            a = real_to_fixed(val);
            #10;
            
            output_real = fixed_to_real(y);
            error = (y == expected) ? 0 : 1;
            
            if (error) begin
                $display("❌ FAIL | Input: %8.4f | Output: %h | Expected: %h | Diff: %h", 
                          val, y, expected, (y - expected));
            end else begin
                $display("✓ PASS | Input: %8.4f | Output: %h | Expected: %h", 
                          val, y, expected);
            end
        end
    endtask

endmodule