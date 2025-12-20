%% =========================================================
%  Minimal GAN Generator Inference (PWQ Version)x_fake
% =========================================================
clear; clc;

% 1. Load trained weights (Sama persis)
load('trained_simple_gan.mat', 'Wg2', 'bg2', 'Wg3', 'bg3');

% 2. Parameters
img_size = 3;
latent_dim = 2;

% 3. Generate image
z = [0 1]'; % Input latent vector sesuai permintaan Anda

% --- Perbedaan hanya di bagian aktivasi ini ---

% Layer 1: Hidden layer menggunakan PWQ
z2 = Wg2 * z + bg2;
ag2 = arrayfun(@(x) pwq_tanh_fixed(x), z2); 

% Layer 2: Output layer menggunakan PWQ
z3 = Wg3 * ag2 + bg3;
x_fake = arrayfun(@(x) pwq_tanh_fixed(x), z3);

% ----------------------------------------------

% 4. Reshape & normalize (Sama persis dengan kode Anda)
generated_img = double(reshape(x_fake/2 + 0.5, img_size, img_size)'); 

% 5. Display
figure;
imagesc(generated_img);
colormap gray; axis image off;
title(['Generated 3x3 (PWQ)']);
colorbar;

% 6. Print values
fprintf('Generated image pixels (3x3):\n');
disp(generated_img);

%% =========================================================
%  Fungsi Pendukung: PWQ Tanh Approximation
% =========================================================
function y = pwq_tanh_fixed(x)
% Piecewise Quadratic tanh approximation (fixed-point)
% Q4.12, symmetric, saturating

    %% Fixed-point config
    WL = 32; FL = 27;
    F  = fimath('RoundingMethod','Nearest',...
                'OverflowAction','Saturate');

    x_fx = fi(x, 1, WL, FL, 'fimath', F);

    %% Coefficients (hasil fitting kamu)
    % Segmen: [0–1], [1–2], [2–4]
    coeff = fi([
        -0.330005   1.101576  -0.006996
        -0.168637   0.699828   0.234964
        -0.012845   0.091424   0.836701
    ], 1, WL, FL, 'fimath', F);

    %% Symmetry
    xi = abs(x_fx);
    s  = sign(x_fx);

    %% Piecewise evaluation
    if xi >= 4
        y = s * fi(1,1,WL,FL,'fimath',F);
    elseif xi >= 2
        p = coeff(3,:);
        y = s * (p(1)*xi*xi + p(2)*xi + p(3));
    elseif xi >= 1
        p = coeff(2,:);
        y = s * (p(1)*xi*xi + p(2)*xi + p(3));
    else
        p = coeff(1,:);
        y = s * (p(1)*xi*xi + p(2)*xi + p(3));
    end

    %% Final saturation
    if y > 1
        y = fi(1,1,WL,FL,'fimath',F);
    elseif y < -1
        y = fi(-1,1,WL,FL,'fimath',F);
    end
end
