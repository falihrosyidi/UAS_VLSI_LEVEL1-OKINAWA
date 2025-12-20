%% =========================================================
%  GAN Inference: Kondisi IDEAL (Floating Point)
% =========================================================
clear; clc;
load('trained_simple_gan_cross.mat');

% Input latent vector (contoh: [0; 1])
z = [0; 1]; 

% --- GENERATOR ---
% Layer 1
z2_g = Wg2 * z + bg2;
ag2 = tanh(z2_g); 
% Layer 2 (Output)
z3_g = Wg3 * ag2 + bg3;
x_fake = tanh(z3_g);

% --- DISCRIMINATOR (Mengecek hasil x_fake) ---
% Layer 1
z2_d = Wd2 * x_fake + bd2;
ad2 = tanh(z2_d);
% Layer 2 (Output)
z3_d = Wd3 * ad2 + bd3;
prediction = 1 / (1 + exp(-z3_d)); % Sigmoid standar

% --- Visualisasi ---
generated_img = reshape(x_fake/2 + 0.5, 3, 3)'; 
figure('Name', 'Kondisi Ideal');
subplot(1,2,1); imagesc(generated_img); colormap gray; axis image;
title('Generator Output'); colorbar;
subplot(1,2,2); bar(prediction); ylim([0 1]);
title(['D Prediction: ', num2str(prediction)]);