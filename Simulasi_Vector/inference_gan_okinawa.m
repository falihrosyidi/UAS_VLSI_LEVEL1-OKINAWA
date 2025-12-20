%% =========================================================
%  Minimal GAN Generator Inference
% =========================================================
clear; clc;

% Load trained weights
load('trained_simple_gan.mat', 'Wg2', 'bg2', 'Wg3', 'bg3');

% Parameters
img_size = 3;
latent_dim = 2;

% Generate image
%z = randn(latent_dim, 1);                    % Random latent vector
z = [0 1]';
ag2 = tanh(Wg2 * z + bg2);                   % Hidden layer
x_fake = tanh(Wg3 * ag2 + bg3);              % Output layer
generated_img = reshape(x_fake/2 + 0.5, img_size, img_size);  % Reshape & normalize

% Display
imagesc(generated_img);
colormap gray; axis image off;
title('Generated 3x3 O+ Pattern');
colorbar;

% Print values
fprintf('Generated image:\n');
disp(generated_img);