%% =========================================================
%  GAN Inference: Kondisi HARDWARE (Fixed Point Q8.24)
% =========================================================
clear; clc;
load('trained_simple_gan_cross.mat');

% Konfigurasi Fixed-Point Q8.24
WL = 32; FL = 24;
F = fimath('RoundingMethod','Nearest','OverflowAction','Saturate');

% Konversi Parameter ke Fixed-Point
W_g2 = fi(Wg2, 1, WL, FL, F); b_g2 = fi(bg2, 1, WL, FL, F);
W_g3 = fi(Wg3, 1, WL, FL, F); b_g3 = fi(bg3, 1, WL, FL, F);
W_d2 = fi(Wd2, 1, WL, FL, F); b_d2 = fi(bd2, 1, WL, FL, F);
W_d3 = fi(Wd3, 1, WL, FL, F); b_d3 = fi(bd3, 1, WL, FL, F);

% Input latent
z_f = fi([0; 1], 1, WL, FL, F);

% --- GENERATOR (Hardware) ---
z2_g = W_g2 * z_f + b_g2;
ag2 = arrayfun(@(val) tanh_hw(val), z2_g);
ag2 = fi(ag2, 1, WL, FL, F);
z3_g = W_g3 * ag2 + b_g3;
x_fake = arrayfun(@(val) tanh_hw(val), z3_g);
x_fake = fi(x_fake, 1, WL, FL, F);

% --- DISCRIMINATOR (Hardware) ---
z2_d = W_d2 * x_fake + b_d2;
ad2 = arrayfun(@(val) tanh_hw(val), z2_d);
ad2 = fi(ad2, 1, WL, FL, F);
z3_d = W_d3 * ad2 + b_d3;
prediction = sigmoid_hw(z3_d);

% --- Visualisasi ---
img_hw = double(reshape(x_fake/2 + 0.5, 3, 3)');
figure('Color', 'w', 'Name', 'Inference Hardware');
subplot(1,2,1); imagesc(img_hw); colormap gray; axis image;
title('Output Gen (Hardware)'); colorbar;
subplot(1,2,2); bar(double(prediction)); ylim([0 1]);
title(['D Prediction: ', num2str(double(prediction))]);

%% --- EXPORT KE EXCEL ---
fprintf('\n=== Menyimpan hasil ke Excel ===\n');

% Sheet 1: Generator Output (x_fake)
sheet1_data = [
    {'Index', 'x_fake (Q8.24)', 'x_fake (Double)', 'x_fake (Hex)'}
];
for i = 1:length(x_fake)
    hex_val = dec2hex(typecast(int32(round(double(x_fake(i)) * 2^24)), 'uint32'), 8);
    sheet1_data = [sheet1_data; {i, double(x_fake(i)), double(x_fake(i)), hex_val}];
end

% Sheet 2: Discriminator Output
sheet2_data = {
    'Output', 'Value (Double)', 'Value (Hex)';
    'D Prediction', double(prediction), dec2hex(typecast(int32(round(double(prediction) * 2^24)), 'uint32'), 8)
};

% Sheet 3: Generator Weights & Biases
sheet3_data = [
    {'Parameter', 'Layer', 'Index', 'Value (Double)', 'Value (Hex)'}
];

% W_g2
[rows, cols] = size(W_g2);
for i = 1:rows
    for j = 1:cols
        hex_val = dec2hex(typecast(int32(round(double(W_g2(i,j)) * 2^24)), 'uint32'), 8);
        sheet3_data = [sheet3_data; {'W_g2', 'Gen Layer 1', sprintf('[%d,%d]', i, j), double(W_g2(i,j)), hex_val}];
    end
end

% b_g2
for i = 1:length(b_g2)
    hex_val = dec2hex(typecast(int32(round(double(b_g2(i)) * 2^24)), 'uint32'), 8);
    sheet3_data = [sheet3_data; {'b_g2', 'Gen Layer 1', sprintf('[%d]', i), double(b_g2(i)), hex_val}];
end

% W_g3
[rows, cols] = size(W_g3);
for i = 1:rows
    for j = 1:cols
        hex_val = dec2hex(typecast(int32(round(double(W_g3(i,j)) * 2^24)), 'uint32'), 8);
        sheet3_data = [sheet3_data; {'W_g3', 'Gen Layer 2', sprintf('[%d,%d]', i, j), double(W_g3(i,j)), hex_val}];
    end
end

% b_g3
for i = 1:length(b_g3)
    hex_val = dec2hex(typecast(int32(round(double(b_g3(i)) * 2^24)), 'uint32'), 8);
    sheet3_data = [sheet3_data; {'b_g3', 'Gen Layer 2', sprintf('[%d]', i), double(b_g3(i)), hex_val}];
end

% Sheet 4: Discriminator Weights & Biases
sheet4_data = [
    {'Parameter', 'Layer', 'Index', 'Value (Double)', 'Value (Hex)'}
];

% W_d2
[rows, cols] = size(W_d2);
for i = 1:rows
    for j = 1:cols
        hex_val = dec2hex(typecast(int32(round(double(W_d2(i,j)) * 2^24)), 'uint32'), 8);
        sheet4_data = [sheet4_data; {'W_d2', 'Disc Layer 1', sprintf('[%d,%d]', i, j), double(W_d2(i,j)), hex_val}];
    end
end

% b_d2
for i = 1:length(b_d2)
    hex_val = dec2hex(typecast(int32(round(double(b_d2(i)) * 2^24)), 'uint32'), 8);
    sheet4_data = [sheet4_data; {'b_d2', 'Disc Layer 1', sprintf('[%d]', i), double(b_d2(i)), hex_val}];
end

% W_d3
[rows, cols] = size(W_d3);
for i = 1:rows
    for j = 1:cols
        hex_val = dec2hex(typecast(int32(round(double(W_d3(i,j)) * 2^24)), 'uint32'), 8);
        sheet4_data = [sheet4_data; {'W_d3', 'Disc Layer 2', sprintf('[%d,%d]', i, j), double(W_d3(i,j)), hex_val}];
    end
end

% b_d3
for i = 1:length(b_d3)
    hex_val = dec2hex(typecast(int32(round(double(b_d3(i)) * 2^24)), 'uint32'), 8);
    sheet4_data = [sheet4_data; {'b_d3', 'Disc Layer 2', sprintf('[%d]', i), double(b_d3(i)), hex_val}];
end

% Tulis ke file Excel
filename = 'gan_hardware_results.xlsx';

try
    writecell(sheet1_data, filename, 'Sheet', 'Generator_Output');
    writecell(sheet2_data, filename, 'Sheet', 'Discriminator_Output');
    writecell(sheet3_data, filename, 'Sheet', 'Generator_Params');
    writecell(sheet4_data, filename, 'Sheet', 'Discriminator_Params');
    
    fprintf('✓ File berhasil disimpan: %s\n', filename);
    fprintf('  - Sheet 1: Generator_Output (x_fake)\n');
    fprintf('  - Sheet 2: Discriminator_Output\n');
    fprintf('  - Sheet 3: Generator_Params (W_g2, b_g2, W_g3, b_g3)\n');
    fprintf('  - Sheet 4: Discriminator_Params (W_d2, b_d2, W_d3, b_d3)\n');
catch ME
    fprintf('✗ Error saat menyimpan file: %s\n', ME.message);
end

%% === FUNGSI HARDWARE (Updated to match Verilog) ===

function y = tanh_hw(a)
    % Implementasi Tanh Hardware sesuai Verilog (Q8.24)
    WIDTH = 32;
    FL = 24;
    
    % Convert input ke Q8.24 fixed-point integer
    a_fixed = int32(round(double(a) * 2^24));
    
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
    
    % 3. Pilih koefisien berdasarkan segment (CORRECTED VALUES dari Verilog)
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

function y = sigmoid_hw(a)
    % Implementasi Sigmoid Hardware sesuai Verilog (Q8.24)
    WIDTH = 32;
    FL = 24;
    
    % Convert input ke Q8.24 fixed-point integer
    a_fixed = int32(round(double(a) * 2^24));
    
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
    
    % 3. Pilih koefisien berdasarkan segment (dari Verilog)
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