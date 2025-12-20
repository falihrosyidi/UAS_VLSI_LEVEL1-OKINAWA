%% =========================================================
%  ANALISIS ERROR SYSTEM-LEVEL GAN: SWEEP FL (Q8.n)
% =========================================================
clear; clc;
load('trained_simple_gan.mat'); % Memuat bobot latih

% Pengaturan Sweep
fl_range = 8:2:24;  % Menguji Fractional Length dari 8 s/d 24
z_latent = [0; 1];  % Input latent vector

% Pre-alokasi Error
mse_gen_output = [];
err_discriminator = [];

% --- 1. HITUNG REFERENSI IDEAL (Floating Point) ---
ag2_id = tanh(Wg2 * z_latent + bg2);
x_fake_id = tanh(Wg3 * ag2_id + bg3);
ad2_id = tanh(Wd2 * x_fake_id + bd2);
pred_id = 1 / (1 + exp(-(Wd3 * ad2_id + bd3)));

% --- 2. LOOP SWEEP FRACTIONAL LENGTH ---
for fl = fl_range
    WL = 8 + fl; % Sign(1) + Int(7) + Fractional(fl)
    F = fimath('RoundingMethod','Floor','OverflowAction','Saturate');
    
    % Kuantisasi Parameter
    W2g_f = fi(Wg2,1,WL,fl,F); B2g_f = fi(bg2,1,WL,fl,F);
    W3g_f = fi(Wg3,1,WL,fl,F); B3g_f = fi(bg3,1,WL,fl,F);
    W2d_f = fi(Wd2,1,WL,fl,F); B2d_f = fi(bd2,1,WL,fl,F);
    W3d_f = fi(Wd3,1,WL,fl,F); B3d_f = fi(bd3,1,WL,fl,F);
    zf = fi(z_latent,1,WL,fl,F);
    
    % --- INFERENCE GENERATOR (Hardware) ---
    z2g_f = W2g_f * zf + B2g_f;
    ag2_f = fi(arrayfun(@(v) pwq_tanh_f(v, fl, WL, F), z2g_f), 1, WL, fl, F);
    z3g_f = W3g_f * ag2_f + B3g_f;
    x_fake_f = arrayfun(@(v) pwq_tanh_f(v, fl, WL, F), z3g_f);
    
    % --- INFERENCE DISCRIMINATOR (Hardware) ---
    z2d_f = W2d_f * fi(x_fake_f,1,WL,fl,F) + B2d_f;
    ad2_f = fi(arrayfun(@(v) pwq_tanh_f(v, fl, WL, F), z2d_f), 1, WL, fl, F);
    z3d_f = W3d_f * ad2_f + B3d_f;
    pred_f = sigmoid_pwl_f(z3d_f, fl, WL, F);
    
    % --- SIMPAN DATA ERROR ---
    % MSE Generator (Pixel-wise)
    mse_gen_output = [mse_gen_output, mean((double(x_fake_id) - double(x_fake_f)).^2)];
    % Error Absolut Discriminator (Prediksi 0-1)
    err_discriminator = [err_discriminator, abs(double(pred_id) - double(pred_f))];
end

% --- 3. PLOT PERBANDINGAN ERROR ---
figure('Color','w','Name','Analisis Error System GAN');

subplot(2,1,1);
plot(fl_range, mse_gen_output, '-ob', 'LineWidth', 1.5);
grid on; ylabel('MSE Generator'); xlabel('Fractional Length (n)');
title('MSE Output Generator (Hardware vs Ideal)');

subplot(2,1,2);
plot(fl_range, err_discriminator, '-or', 'LineWidth', 1.5);
grid on; ylabel('Abs Error Prediction'); xlabel('Fractional Length (n)');
title('Error Prediksi Discriminator (Hardware vs Ideal)');

%% =========================================================
%  FUNGSI PENDUKUNG (Aproksimasi)
% =========================================================

function y = pwq_tanh_f(x, fl, wl, F)
    % PWQ Tanh dengan koefisien fitting kuadratik
    c = fi([-0.330005, 1.101576, -0.006996; ... 
            -0.168637, 0.699828, 0.234964; ... 
            -0.012845, 0.091424, 0.836701], 1, wl, fl, F);
    xf = fi(x, 1, wl, fl, F);
    xi = abs(xf); s = sign(xf);
    if xi >= 4,     val = fi(1,1,wl,fl,F);
    elseif xi >= 2, p = c(3,:); val = p(1)*xi*xi + p(2)*xi + p(3);
    elseif xi >= 1, p = c(2,:); val = p(1)*xi*xi + p(2)*xi + p(3);
    else,           p = c(1,:); val = p(1)*xi*xi + p(2)*xi + p(3);
    end
    y = s * val;
end

function y = sigmoid_pwl_f(x, fl, wl, F)
    % PWL Sigmoid (Zerun Li et al.)
    xf = fi(x, 1, wl, fl, F);
    ax = abs(xf);
    if ax < 1,         val = fi(0.25,1,wl,fl,F)*ax + fi(0.5,1,wl,fl,F);
    elseif ax < 2.375, val = fi(0.125,1,wl,fl,F)*ax + fi(0.625,1,wl,fl,F);
    elseif ax < 5,     val = fi(0.03125,1,wl,fl,F)*ax + fi(0.84375,1,wl,fl,F);
    else,              val = fi(1,1,wl,fl,F);
    end
    if x < 0, y = fi(1,1,wl,fl,F) - val; else, y = val; end
end