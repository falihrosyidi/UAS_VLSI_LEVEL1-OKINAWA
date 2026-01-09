% Implementasi Sigmoid dari Verilog dalam MATLAB
% Format: Q8.24 (8 bit integer, 24 bit fractional)

clear; clc; close all;

% Fungsi sigmoid hardware (persis seperti Verilog)
function y = sigmoid_hw(a)
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
    TH_15 = hex2dec('01800000'); % 1.5
    TH_35 = hex2dec('03800000'); % 3.5
    TH_60 = hex2dec('06000000'); % 6.0
    
    % 3. Pilih koefisien berdasarkan segment
    if a_pos >= TH_60  % a_pos >= 6.0
        p1 = int32(hex2dec('00000000'));
        p2 = int32(hex2dec('00000000'));
        p3 = int32(hex2dec('01000000'));
    elseif a_pos >= TH_35  % 3.5 <= a_pos < 6.0
        p1 = int32(typecast(uint32(hex2dec('FFFED1F2')), 'int32'));
        p2 = int32(hex2dec('000DB91F'));
        p3 = int32(hex2dec('00D7418D'));
    elseif a_pos >= TH_15  % 1.5 <= a_pos < 3.5
        p1 = int32(typecast(uint32(hex2dec('FFF852B5')), 'int32'));
        p2 = int32(hex2dec('0039569F'));
        p3 = int32(hex2dec('008D387A'));
    else  % 0.0 <= a_pos < 1.5
        p1 = int32(typecast(uint32(hex2dec('FFF69FE0')), 'int32'));
        p2 = int32(hex2dec('0044E38A'));
        p3 = int32(hex2dec('007F7143'));
    end
    
    % 4. Hitung a_pos^2
    a_sq_full = int64(a_pos) * int64(a_pos);
    a_sq = int32(bitshift(a_sq_full, -FL));
    
    % 5. Multiply
    term1_full = int64(p1) * int64(a_sq);
    term2_full = int64(p2) * int64(a_pos);
    
    term1 = int32(bitshift(term1_full, -FL));
    term2 = int32(bitshift(term2_full, -FL));
    
    % 6. Accumulate
    ONE = int32(hex2dec('01000000'));
    ZERO = int32(0);
    
    y_abs = term1 + term2 + p3;
    
    % Saturasi: 0 <= y_abs <= 1
    if y_abs > ONE
        y_abs_sat = ONE;
    elseif y_abs < ZERO
        y_abs_sat = ZERO;
    else
        y_abs_sat = y_abs;
    end
    
    % Apply symmetry: f(-x) = 1 - f(x)
    if sign == 1
        y_sigmoid_val = ONE - y_abs_sat;
    else
        y_sigmoid_val = y_abs_sat;
    end
    
    % Convert back to floating point
    y = double(y_sigmoid_val) / 2^24;
end

% Test range
x = linspace(-8, 8, 1000);

% Hitung sigmoid hardware dan asli
y_hw = zeros(size(x));
for i = 1:length(x)
    y_hw(i) = sigmoid_hw(x(i));
end

y_true = 1 ./ (1 + exp(-x));

% Hitung error
abs_error = abs(y_hw - y_true);
max_abs_error = max(abs_error);

% Plot
figure('Position', [100 100 1200 800]);

% Plot 1: Perbandingan fungsi
subplot(2,1,1);
plot(x, y_true, 'b-', 'LineWidth', 2, 'DisplayName', 'Sigmoid Asli');
hold on;
plot(x, y_hw, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Sigmoid Hardware');
grid on;
xlabel('x');
ylabel('sigmoid(x)');
title('Perbandingan Sigmoid Asli vs Hardware Implementation');
legend('Location', 'best');
xlim([-8 8]);
ylim([0 1]);

% Plot 2: Error
subplot(2,1,2);
plot(x, abs_error, 'k-', 'LineWidth', 1.5);
grid on;
xlabel('x');
ylabel('Absolute Error');
title(sprintf('Absolute Error (Max = %.6f)', max_abs_error));
xlim([-8 8]);

% Display hasil
fprintf('=== SIGMOID HARDWARE ANALYSIS ===\n');
fprintf('Maximum Absolute Error: %.8f\n', max_abs_error);
fprintf('Mean Absolute Error: %.8f\n', mean(abs_error));
fprintf('RMSE: %.8f\n', sqrt(mean(abs_error.^2)));

% Test beberapa nilai spesifik
fprintf('\n=== Test Values ===\n');
test_vals = [-6, -3.5, -1.5, 0, 1.5, 3.5, 6];
for val = test_vals
    hw_result = sigmoid_hw(val);
    true_result = 1/(1 + exp(-val));
    fprintf('x = %5.1f: HW = %.6f, True = %.6f, Error = %.6f\n', ...
            val, hw_result, true_result, abs(hw_result - true_result));
end

% Analisis error per segment
fprintf('\n=== Error Analysis per Segment ===\n');
segments = {
    '[0, 1.5)', 0, 1.5;
    '[1.5, 3.5)', 1.5, 3.5;
    '[3.5, 6)', 3.5, 6;
    '[6, inf)', 6, 8
};

for i = 1:size(segments, 1)
    mask = (abs(x) >= segments{i,2}) & (abs(x) < segments{i,3});
    if any(mask)
        seg_error = abs_error(mask);
        fprintf('Segment %s: Max Error = %.6f, Mean Error = %.6f\n', ...
                segments{i,1}, max(seg_error), mean(seg_error));
    end
end