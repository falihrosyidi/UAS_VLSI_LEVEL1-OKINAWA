% Implementasi Tanh dari Verilog dalam MATLAB
% Format: Q8.24 (8 bit integer, 24 bit fractional)

clear; clc; close all;

% Fungsi untuk verifikasi koefisien dari hex
function dec_val = hex_to_fixed(hex_str)
    val = hex2dec(hex_str);
    if val >= 2^31
        val = val - 2^32;  % Two's complement
    end
    dec_val = double(val) / 2^24;
end

% Verifikasi koefisien dari Verilog (CORRECTED)
fprintf('=== VERIFIKASI KOEFISIEN TANH (CORRECTED) ===\n');
fprintf('Segmen 1 [0.0-1.0]:\n');
fprintf('  p1 (FFABFF38) = %.6f (expected: -0.330005)\n', hex_to_fixed('FFABFF38'));
fprintf('  p2 (011A0A5A) = %.6f (expected:  1.101576)\n', hex_to_fixed('011A0A5A'));
fprintf('  p3 (FFFE3568) = %.6f (expected: -0.006996)\n', hex_to_fixed('FFFE3568'));
fprintf('Segmen 2 [1.0-2.0]:\n');
fprintf('  p1 (FFD4D35C) = %.6f (expected: -0.168637)\n', hex_to_fixed('FFD4D35C'));
fprintf('  p2 (00B327E0) = %.6f (expected:  0.699828)\n', hex_to_fixed('00B327E0'));
fprintf('  p3 (003C26AA) = %.6f (expected:  0.234964)\n', hex_to_fixed('003C26AA'));
fprintf('Segmen 3 [2.0-4.0]:\n');
fprintf('  p1 (FFFCB548) = %.6f (expected: -0.012845)\n', hex_to_fixed('FFFCB548'));
fprintf('  p2 (001767BB) = %.6f (expected:  0.091424)\n', hex_to_fixed('001767BB'));
fprintf('  p3 (00D63241) = %.6f (expected:  0.836701)\n', hex_to_fixed('00D63241'));
fprintf('\n');

% Fungsi tanh hardware (persis seperti Verilog dengan koefisien yang diperbaiki)
function y = tanh_hw(a)
    WIDTH = 32;
    FL = 24;
    
    % Convert input ke Q8.24
    a_fixed = int32(round(a * 2^24));
    
    % 1. Ambil tanda dan nilai absolut
    if a_fixed < 0
        sign = 1;
        a_pos = -a_fixed;
    else
        sign = 0;
        a_pos = a_fixed;
    end
    
    % 2. Threshold dalam Q8.24
    TH_10 = hex2dec('01000000'); % 1.0
    TH_20 = hex2dec('02000000'); % 2.0
    TH_40 = hex2dec('04000000'); % 4.0
    
    % 3. Pilih koefisien berdasarkan segment (CORRECTED VALUES)
    if a_pos >= TH_40  % a_pos >= 4.0
        p1 = int32(hex2dec('00000000'));
        p2 = int32(hex2dec('00000000'));
        p3 = int32(hex2dec('01000000'));
    elseif a_pos >= TH_20  % 2.0 <= a_pos < 4.0
        % -0.012845, 0.091424, 0.836701
        p1 = int32(typecast(uint32(hex2dec('FFFCB631')), 'int32'));
        p2 = int32(hex2dec('00176790'));
        p3 = int32(hex2dec('00D63209'));
    elseif a_pos >= TH_10  % 1.0 <= a_pos < 2.0
        % -0.168637, 0.699828, 0.234964
        p1 = int32(typecast(uint32(hex2dec('FFD4D435')), 'int32'));
        p2 = int32(hex2dec('00B327EE'));
        p3 = int32(hex2dec('003C269A'));
    else  % 0.0 <= a_pos < 1.0
        % -0.330005, 1.101576, -0.006996
        p1 = int32(typecast(uint32(hex2dec('FFAB84CB')), 'int32'));
        p2 = int32(hex2dec('011A00E2'));
        p3 = int32(typecast(uint32(hex2dec('FFFE3583')), 'int32'));
    end
    
    % 4. Hitung a_pos^2
    a_pos_sq_full = int64(a_pos) * int64(a_pos);
    a_pos_sq = int32(bitshift(a_pos_sq_full, -FL));
    
    % 5. Multiply
    term1_full = int64(p1) * int64(a_pos_sq);
    term2_full = int64(p2) * int64(a_pos);
    
    term1 = int32(bitshift(term1_full, -FL));
    term2 = int32(bitshift(term2_full, -FL));
    
    % 6. Accumulate
    y_abs = term1 + term2 + p3;
    
    % 7. Kembalikan tanda
    if sign == 1
        y_signed = -y_abs;
    else
        y_signed = y_abs;
    end
    
    % 8. Saturasi: -1.0 <= y <= 1.0
    ONE_POS = int32(hex2dec('01000000'));
    ONE_NEG = int32(typecast(uint32(hex2dec('FF000000')), 'int32'));
    
    if y_signed > ONE_POS
        y_sat = ONE_POS;
    elseif y_signed < ONE_NEG
        y_sat = ONE_NEG;
    else
        y_sat = y_signed;
    end
    
    % Convert back to floating point
    y = double(y_sat) / 2^24;
end

% Test range dengan lebih banyak detail
x = linspace(-6, 6, 2000);

% Hitung tanh hardware dan asli
y_hw = zeros(size(x));
for i = 1:length(x)
    y_hw(i) = tanh_hw(x(i));
end

y_true = tanh(x);

% Hitung error
abs_error = abs(y_hw - y_true);
max_abs_error = max(abs_error);

% Plot dengan detail lebih baik
figure('Position', [100 100 1400 900]);

% Plot 1: Perbandingan fungsi (full range)
subplot(3,2,1);
plot(x, y_true, 'b-', 'LineWidth', 2, 'DisplayName', 'Tanh Asli');
hold on;
plot(x, y_hw, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Tanh Hardware');
xline([-4, -2, -1, 1, 2, 4], '--k', 'Alpha', 0.3);
grid on;
xlabel('x');
ylabel('tanh(x)');
title('Perbandingan Tanh: Full Range');
legend('Location', 'best');
xlim([-6 6]);
ylim([-1 1]);

% Plot 2: Zoom di segment 1 [0, 1]
subplot(3,2,2);
mask = (x >= 0) & (x <= 1);
plot(x(mask), y_true(mask), 'b-', 'LineWidth', 2, 'DisplayName', 'Asli');
hold on;
plot(x(mask), y_hw(mask), 'r--', 'LineWidth', 1.5, 'DisplayName', 'HW');
grid on;
xlabel('x');
ylabel('tanh(x)');
title('Segment 1: [0, 1]');
legend('Location', 'best');

% Plot 3: Zoom di segment 2 [1, 2]
subplot(3,2,3);
mask = (x >= 1) & (x <= 2);
plot(x(mask), y_true(mask), 'b-', 'LineWidth', 2, 'DisplayName', 'Asli');
hold on;
plot(x(mask), y_hw(mask), 'r--', 'LineWidth', 1.5, 'DisplayName', 'HW');
grid on;
xlabel('x');
ylabel('tanh(x)');
title('Segment 2: [1, 2]');
legend('Location', 'best');

% Plot 4: Zoom di segment 3 [2, 4]
subplot(3,2,4);
mask = (x >= 2) & (x <= 4);
plot(x(mask), y_true(mask), 'b-', 'LineWidth', 2, 'DisplayName', 'Asli');
hold on;
plot(x(mask), y_hw(mask), 'r--', 'LineWidth', 1.5, 'DisplayName', 'HW');
grid on;
xlabel('x');
ylabel('tanh(x)');
title('Segment 3: [2, 4]');
legend('Location', 'best');

% Plot 5: Error full range
subplot(3,2,5);
plot(x, abs_error, 'k-', 'LineWidth', 1.5);
hold on;
xline([-4, -2, -1, 1, 2, 4], '--r', 'Alpha', 0.3);
grid on;
xlabel('x');
ylabel('Absolute Error');
title(sprintf('Absolute Error (Max = %.6f)', max_abs_error));
xlim([-6 6]);

% Plot 6: Error zoom di area kritis
subplot(3,2,6);
mask = (x >= -3) & (x <= 3);
plot(x(mask), abs_error(mask), 'k-', 'LineWidth', 1.5);
hold on;
xline([-2, -1, 1, 2], '--r', 'Alpha', 0.5);
grid on;
xlabel('x');
ylabel('Absolute Error');
title('Error: Detail View [-3, 3]');

% Display hasil
fprintf('=== TANH HARDWARE ANALYSIS ===\n');
fprintf('Maximum Absolute Error: %.8f\n', max_abs_error);
fprintf('Mean Absolute Error: %.8f\n', mean(abs_error));
fprintf('RMSE: %.8f\n', sqrt(mean(abs_error.^2)));

% Test beberapa nilai spesifik di boundary
fprintf('\n=== Test Values at Boundaries ===\n');
test_vals = [-4, -2, -1, -0.5, 0, 0.5, 1, 2, 4];
for val = test_vals
    hw_result = tanh_hw(val);
    true_result = tanh(val);
    fprintf('x = %5.1f: HW = %.6f, True = %.6f, Error = %.6f\n', ...
            val, hw_result, true_result, abs(hw_result - true_result));
end

% Analisis error per segment
fprintf('\n=== Error Analysis per Segment ===\n');
segments = {
    '[0, 1)', 0, 1;
    '[1, 2)', 1, 2;
    '[2, 4)', 2, 4;
    '[4, inf)', 4, 6
};

for i = 1:size(segments, 1)
    mask = (abs(x) >= segments{i,2}) & (abs(x) < segments{i,3});
    if any(mask)
        seg_error = abs_error(mask);
        fprintf('Segment %s: Max Error = %.6f, Mean Error = %.6f\n', ...
                segments{i,1}, max(seg_error), mean(seg_error));
    end
end