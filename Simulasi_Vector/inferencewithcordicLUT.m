%% =========================================================
%  GAN Inference: CORDIC Tanh & Sigmoid LUT (10-bit)
% =========================================================
clear; clc; close all;

% 1. Load weights (Pastikan file ini ada di folder yang sama)
load('trained_simple_gan.mat'); 

% 2. Parameters
num_iter = 12;
img_size = 3;
latent_dim = 2;

% 3. Pre-generate Sigmoid LUT (10-bit, x_range = 4)
lut_size = 2^10;
x_range = 4; 
lut_x = linspace(-x_range, x_range, lut_size);
lut_raw = 1 ./ (1 + exp(-lut_x));

% Simulasi Quantization Q0.16 dan Padding ke Q5.27
lut_q0_16 = round(lut_raw * (2^16 - 1)); 
lut_q5_27 = lut_q0_16 * 2^11; 

% 4. GENERATOR (Forward Pass)
z = [0; 1];
z2 = Wg2 * z + bg2;
ag2 = arrayfun(@(x) cordic_tanh_improved(x, num_iter), z2);
z3 = Wg3 * ag2 + bg3;
x_fake = arrayfun(@(x) cordic_tanh_improved(x, num_iter), z3);

% 5. DISCRIMINATOR (Forward Pass)
zd2 = Wd2 * x_fake + bd2;
ad2 = arrayfun(@(x) cordic_tanh_improved(x, num_iter), zd2);
zd3 = Wd3 * ad2 + bd3; 

% Pemetaan ke Alamat LUT
zd3_clamped = max(min(zd3, x_range), -x_range);
addr = round(((zd3_clamped + x_range) / (2 * x_range)) * (lut_size - 1)) + 1;
y_score_fixed = lut_q5_27(addr); 
y_score_real = y_score_fixed / 2^27;

%% --- BAGIAN BARU: MENGELUARKAN & MENYIMPAN DATA ---

% A. Menampilkan (Mengeluarkan) Nilai x_fake ke Command Window
fprintf('\n--- DATA OUTPUT GENERATOR (x_fake) ---\n');
disp(x_fake'); % Menampilkan 9 nilai piksel secara horizontal


% C. Menampilkan Hasil Diskriminator
fprintf('\n--- HASIL DISKRIMINATOR ---\n');
fprintf('Alamat LUT: 0x%s\n', dec2hex(addr-1, 3));
fprintf('Skor Desimal: %.6f\n', y_score_real);

%% --- VISUALISASI ---
generated_img = reshape(x_fake/2 + 0.5, img_size, img_size)';
figure(1); % Memaksa jendela figure muncul
imagesc(generated_img); 
colormap gray; axis image off;
colorbar;
title(['Skor Sigmoid LUT: ', num2str(y_score_real)]);
drawnow; % Memastikan gambar dirender segera

%% =========================================================
%  Fungsi Pendukung (Wajib ada di bawah script)
% =========================================================
function y = cordic_tanh_improved(x, iter)
    v = [1; 0]; 
    curr_x = x;
    for i = -2:0 % Range Expansion
        d = (curr_x >= 0) * 2 - 1;
        v_old = v;
        alpha = atanh(1 - 2^(i-3)); 
        v(1) = v_old(1) + d * v_old(2) * (1 - 2^(i-3));
        v(2) = v_old(2) + d * v_old(1) * (1 - 2^(i-3));
        curr_x = curr_x - d * alpha;
    end
    for i = 1:iter
        d = (curr_x >= 0) * 2 - 1;
        v_old = v;
        v(1) = v_old(1) + d * v_old(2) * 2^(-i);
        v(2) = v_old(2) + d * v_old(1) * 2^(-i);
        curr_x = curr_x - d * atanh(2^(-i));
        if i == 4 || i == 13
             v_old = v;
             v(1) = v_old(1) + d * v_old(2) * 2^(-i);
             v(2) = v_old(2) + d * v_old(1) * 2^(-i);
             curr_x = curr_x - d * atanh(2^(-i));
        end
    end
    y = v(2) / v(1);
    if y > 1, y = 1; elseif y < -1, y = -1; end
end