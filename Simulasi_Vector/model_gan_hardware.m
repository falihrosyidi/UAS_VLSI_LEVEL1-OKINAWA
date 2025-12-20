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
ag2 = arrayfun(@(val) pwq_tanh_fixed(val), z2_g);
ag2 = fi(ag2, 1, WL, FL, F);
z3_g = W_g3 * ag2 + b_g3;
x_fake = arrayfun(@(val) pwq_tanh_fixed(val), z3_g);
x_fake = fi(x_fake, 1, WL, FL, F);

% --- DISCRIMINATOR (Hardware) ---
z2_d = W_d2 * x_fake + b_d2;
ad2 = arrayfun(@(val) pwq_tanh_fixed(val), z2_d);
ad2 = fi(ad2, 1, WL, FL, F);
z3_d = W_d3 * ad2 + b_d3;
prediction = sigmoid_pwl_li(z3_d);

% --- Visualisasi ---
img_hw = double(reshape(x_fake/2 + 0.5, 3, 3)');
figure('Color', 'w', 'Name', 'Inference Hardware');
subplot(1,2,1); imagesc(img_hw); colormap gray; axis image;
title('Output Gen (Hardware)'); colorbar;
subplot(1,2,2); bar(double(prediction)); ylim([0 1]);
title(['D Prediction: ', num2str(double(prediction))]);

%% === FUNGSI HARDWARE ===
function y = pwq_tanh_fixed(x)
    WL = 32; FL = 24;
    F = fimath('RoundingMethod','Floor','OverflowAction','Saturate');
    x_fx = fi(x, 1, WL, FL, F);
    
    % Koefisien Fitting yang Anda Berikan
    coeff = fi([-0.330005, 1.101576, -0.006996; ... % 0-1
                 -0.168637, 0.699828, 0.234964; ... % 1-2
                 -0.012845, 0.091424, 0.836701], 1, WL, FL, F);
    
    xi = abs(x_fx);
    s = sign(x_fx);
    
    if xi >= 4
        y = s * fi(1.0, 1, WL, FL, F);
    elseif xi >= 2
        p = coeff(3,:); y = s * (p(1)*xi*xi + p(2)*xi + p(3));
    elseif xi >= 1
        p = coeff(2,:); y = s * (p(1)*xi*xi + p(2)*xi + p(3));
    else
        p = coeff(1,:); y = s * (p(1)*xi*xi + p(2)*xi + p(3));
    end
    
    % Final saturation
    if y > 1; y = fi(1,1,WL,FL,F); elseif y < -1; y = fi(-1,1,WL,FL,F); end
end

function y = sigmoid_pwl_li(x)
    % Implementasi PWL Sigmoid Li et al. (Format Q8.24)
    WL = 32; FL = 24; F = fimath('RoundingMethod','Nearest','OverflowAction','Saturate');
    ax = abs(x);
    if ax < 1
        val = fi(0.25,1,WL,FL,F)*ax + fi(0.5,1,WL,FL,F);
    elseif ax < 2.375
        val = fi(0.125,1,WL,FL,F)*ax + fi(0.625,1,WL,FL,F);
    elseif ax < 5
        val = fi(0.03125,1,WL,FL,F)*ax + fi(0.84375,1,WL,FL,F);
    else
        val = fi(1.0,1,WL,FL,F);
    end
    if x < 0; y = fi(1,1,WL,FL,F) - val; else; y = val; end
end