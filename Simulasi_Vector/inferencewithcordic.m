%% =========================================================
%  Minimal GAN Generator Inference (CORDIC Version)x_fake
% =========================================================
clear; clc;

% 1. Load trained weights (Sama persis)
load('trained_simple_gan.mat', 'Wg2', 'bg2', 'Wg3', 'bg3');

% 2. Parameters
img_size = 3;
latent_dim = 2;
num_iter = 12 % Konfigurasi jumlah iterasi CORDIC

% 3. Generate image
z = [0 1]'; % Input latent vector sesuai permintaan Anda

% --- Perbedaan hanya di bagian aktivasi ini ---

% Layer 1: Hidden layer menggunakan CORDIC
z2 = Wg2 * z + bg2;
ag2 = arrayfun(@(x) cordic_tanh_improved(x, num_iter), z2); 

% Layer 2: Output layer menggunakan CORDIC
z3 = Wg3 * ag2 + bg3;
x_fake = arrayfun(@(x) cordic_tanh_improved(x, num_iter), z3);

% ----------------------------------------------

% 4. Reshape & normalize (Sama persis dengan kode Anda)
generated_img = reshape(x_fake/2 + 0.5, img_size, img_size)'; 

% 5. Display
figure;
imagesc(generated_img);
colormap gray; axis image off;
title(['Generated 3x3 (CORDIC ', num2str(num_iter), ' Iter)']);
colorbar;

% 6. Print values
fprintf('Generated image pixels (3x3):\n');
disp(generated_img);

%% =========================================================
%  Fungsi Pendukung: CORDIC Tanh Approximation
% =========================================================
function y = cordic_tanh_improved(x, iter)
    % Inisialisasi vektor [cosh; sinh]
    v = [1; 0]; 
    curr_x = x;
    
    % 1. RANGE EXPANSION (Iterasi Negatif: i = -2, -1, 0)
    % Ini memperluas batas konvergensi agar bisa mencapai tanh > 0.8
    for i = -2:0
        d = (curr_x >= 0) * 2 - 1;
        v_old = v;
        
        % Untuk i <= 0, rumus sedikit berbeda untuk menjaga stabilitas
        % Kita menggunakan nilai atanh(1 - 2^(i-2)) atau nilai konstanta tetap
        alpha = atanh(1 - 2^(i-3)); 
        
        v(1) = v_old(1) + d * v_old(2) * (1 - 2^(i-3));
        v(2) = v_old(2) + d * v_old(1) * (1 - 2^(i-3));
        curr_x = curr_x - d * alpha;
    end

    % 2. ITERASI STANDAR (i = 1 s/d iter)
    for i = 1:iter
        d = (curr_x >= 0) * 2 - 1;
        v_old = v;
        v(1) = v_old(1) + d * v_old(2) * 2^(-i);
        v(2) = v_old(2) + d * v_old(1) * 2^(-i);
        curr_x = curr_x - d * atanh(2^(-i));
        
        % Aturan konvergensi hiperbolik (ulang i = 4, 13)
        if i == 4 || i == 13
             v_old = v;
             v(1) = v_old(1) + d * v_old(2) * 2^(-i);
             v(2) = v_old(2) + d * v_old(1) * 2^(-i);
             curr_x = curr_x - d * atanh(2^(-i));
        end
    end
    
    y = v(2) / v(1);
    
    % Saturasi akhir agar tidak melebihi 1
    if y > 1, y = 1; elseif y < -1, y = -1; end
end