%% =========================================================
%  Fixed-Point GAN Generator - Fraction Length Sweep
%  Integer bits sudah fixed, sweep fraction length
% =========================================================
clear; clc; close all;

%% 1. Load trained weights
load('trained_simple_gan.mat', 'Wg2', 'bg2', 'Wg3', 'bg3');

%% 2. Parameters
img_size = 3;
latent_dim = 2;
z_input = [0 1]'; % Input latent vector

%% 3. Floating-Point Reference (Ground Truth)
fprintf('=== Computing Floating-Point Reference ===\n');
% Layer 1
z2_fp = Wg2 * z_input + bg2;
ag2_fp = tanh(z2_fp);
% Layer 2
z3_fp = Wg3 * ag2_fp + bg3;
x_fake_fp = tanh(z3_fp);
% Output image
img_fp = double(reshape(x_fake_fp/2 + 0.5, img_size, img_size)');

fprintf('Floating-Point Output Image:\n');
disp(img_fp);

%% 4. Analisis Range untuk Validasi Integer Bits
fprintf('\n=== Data Range Analysis ===\n');
fprintf('Input (z):         [%.4f, %.4f] → IB=2 (Q1.n) ✓\n', min(z_input), max(z_input));
fprintf('Weight Wg2:        [%.4f, %.4f] → IB=3 (Q2.n) ', min(Wg2(:)), max(Wg2(:)));
if max(abs(Wg2(:))) < 4, fprintf('✓\n'); else, fprintf('⚠ OVERFLOW RISK!\n'); end
fprintf('Bias bg2:          [%.4f, %.4f] → IB=3 (Q2.n) ', min(bg2(:)), max(bg2(:)));
if max(abs(bg2(:))) < 4, fprintf('✓\n'); else, fprintf('⚠ OVERFLOW RISK!\n'); end
fprintf('Hidden act (ag2):  [%.4f, %.4f] → IB=2 (Q1.n) ✓\n', min(ag2_fp), max(ag2_fp));
fprintf('Weight Wg3:        [%.4f, %.4f] → IB=3 (Q2.n) ', min(Wg3(:)), max(Wg3(:)));
if max(abs(Wg3(:))) < 4, fprintf('✓\n'); else, fprintf('⚠ OVERFLOW RISK!\n'); end
fprintf('Bias bg3:          [%.4f, %.4f] → IB=3 (Q2.n) ', min(bg3(:)), max(bg3(:)));
if max(abs(bg3(:))) < 4, fprintf('✓\n'); else, fprintf('⚠ OVERFLOW RISK!\n'); end
fprintf('Output (x_fake):   [%.4f, %.4f] → IB=2 (Q1.n) ✓\n', min(x_fake_fp), max(x_fake_fp));

% Analisis accumulator range
fprintf('\n=== Accumulator Range Analysis ===\n');
fprintf('Layer 1 pre-activation: [%.4f, %.4f]\n', min(z2_fp), max(z2_fp));
fprintf('Layer 2 pre-activation: [%.4f, %.4f]\n', min(z3_fp), max(z3_fp));
max_acc = max(abs([z2_fp(:); z3_fp(:)]));
fprintf('Max accumulator value: %.4f\n', max_acc);
if max_acc < 64
    fprintf('Recommended IB for accumulator: 7 bits (Q6.n) ✓\n');
elseif max_acc < 32
    fprintf('Recommended IB for accumulator: 6 bits (Q5.n) - bisa lebih kecil!\n');
else
    fprintf('⚠ WARNING: Butuh IB > 7 bits untuk accumulator!\n');
end

%% 5. Fixed Integer Bits Configuration
fprintf('\n=== Fixed Integer Bits Configuration ===\n');
IB_input = 2;      % Q1.n (range [-2, 2))
IB_weight = 3;     % Q2.n (range [-4, 4))
IB_bias = 3;       % Q2.n (range [-4, 4))
IB_acc = 7;        % Q6.n (range [-64, 64)) - bisa disesuaikan
IB_act = 2;        % Q1.n (range [-2, 2))
IB_tanh = 2;       % Q1.n (range [-2, 2)) untuk output tanh

fprintf('Input/Activation:  Q%d.n (integer bits = %d)\n', IB_input, IB_input);
fprintf('Weight/Bias:       Q%d.n (integer bits = %d)\n', IB_weight, IB_weight);
fprintf('Accumulator:       Q%d.n (integer bits = %d)\n', IB_acc, IB_acc);
fprintf('Tanh output:       Q%d.n (integer bits = %d)\n', IB_tanh, IB_tanh);

%% 6. Define Fraction Length Sweep Range
fprintf('\n=== Fraction Length Sweep Configuration ===\n');

% Fraction lengths yang akan di-test
FL_input_range = 4:2:16;      % Input: 4, 6, 8, 10, 12, 14, 16
FL_weight_range = 6:2:18;     % Weight: 6, 8, 10, 12, 14, 16, 18 (lebih penting!)
FL_bias_range = 6:2:16;       % Bias: 6, 8, 10, 12, 14, 16
FL_acc_range = 8:2:20;        % Accumulator: 8, 10, 12, 14, 16, 18, 20
FL_act_range = 4:2:14;        % Activation: 4, 6, 8, 10, 12, 14
FL_tanh_range = 6:2:16;       % Tanh: 6, 8, 10, 12, 14, 16

fprintf('Sweeping:\n');
fprintf('  FL_input:  %s\n', mat2str(FL_input_range));
fprintf('  FL_weight: %s\n', mat2str(FL_weight_range));
fprintf('  FL_bias:   %s\n', mat2str(FL_bias_range));
fprintf('  FL_acc:    %s\n', mat2str(FL_acc_range));
fprintf('  FL_act:    %s\n', mat2str(FL_act_range));
fprintf('  FL_tanh:   %s\n', mat2str(FL_tanh_range));

%% 7. Strategy 1: Sweep Individual Components (Fixed others at medium)
fprintf('\n=== STRATEGY 1: Individual Component Sweep ===\n');
fprintf('Sweep satu komponen, yang lain fixed di nilai medium\n\n');

% Baseline (medium values)
FL_base = struct();
FL_base.input = 10;
FL_base.weight = 12;
FL_base.bias = 10;
FL_base.acc = 14;
FL_base.act = 8;
FL_base.tanh = 10;

results_individual = struct();

% Sweep Input FL
fprintf('Sweeping Input FL...\n');
for i = 1:length(FL_input_range)
    config = FL_base;
    config.input = FL_input_range(i);
    [mse, mae, psnr, bits, img_out] = evaluate_config(config, IB_input, IB_weight, ...
        IB_bias, IB_acc, IB_act, IB_tanh, z_input, Wg2, bg2, Wg3, bg3, img_size, img_fp);
    results_individual.input(i) = struct('FL', FL_input_range(i), 'MSE', mse, ...
        'MAE', mae, 'PSNR', psnr, 'Bits', bits, 'Image', img_out);
end

% Sweep Weight FL
fprintf('Sweeping Weight FL...\n');
for i = 1:length(FL_weight_range)
    config = FL_base;
    config.weight = FL_weight_range(i);
    [mse, mae, psnr, bits, img_out] = evaluate_config(config, IB_input, IB_weight, ...
        IB_bias, IB_acc, IB_act, IB_tanh, z_input, Wg2, bg2, Wg3, bg3, img_size, img_fp);
    results_individual.weight(i) = struct('FL', FL_weight_range(i), 'MSE', mse, ...
        'MAE', mae, 'PSNR', psnr, 'Bits', bits, 'Image', img_out);
end

% Sweep Bias FL
fprintf('Sweeping Bias FL...\n');
for i = 1:length(FL_bias_range)
    config = FL_base;
    config.bias = FL_bias_range(i);
    [mse, mae, psnr, bits, img_out] = evaluate_config(config, IB_input, IB_weight, ...
        IB_bias, IB_acc, IB_act, IB_tanh, z_input, Wg2, bg2, Wg3, bg3, img_size, img_fp);
    results_individual.bias(i) = struct('FL', FL_bias_range(i), 'MSE', mse, ...
        'MAE', mae, 'PSNR', psnr, 'Bits', bits, 'Image', img_out);
end

% Sweep Accumulator FL
fprintf('Sweeping Accumulator FL...\n');
for i = 1:length(FL_acc_range)
    config = FL_base;
    config.acc = FL_acc_range(i);
    [mse, mae, psnr, bits, img_out] = evaluate_config(config, IB_input, IB_weight, ...
        IB_bias, IB_acc, IB_act, IB_tanh, z_input, Wg2, bg2, Wg3, bg3, img_size, img_fp);
    results_individual.acc(i) = struct('FL', FL_acc_range(i), 'MSE', mse, ...
        'MAE', mae, 'PSNR', psnr, 'Bits', bits, 'Image', img_out);
end

% Sweep Activation FL
fprintf('Sweeping Activation FL...\n');
for i = 1:length(FL_act_range)
    config = FL_base;
    config.act = FL_act_range(i);
    [mse, mae, psnr, bits, img_out] = evaluate_config(config, IB_input, IB_weight, ...
        IB_bias, IB_acc, IB_act, IB_tanh, z_input, Wg2, bg2, Wg3, bg3, img_size, img_fp);
    results_individual.act(i) = struct('FL', FL_act_range(i), 'MSE', mse, ...
        'MAE', mae, 'PSNR', psnr, 'Bits', bits, 'Image', img_out);
end

% Sweep Tanh FL
fprintf('Sweeping Tanh FL...\n');
for i = 1:length(FL_tanh_range)
    config = FL_base;
    config.tanh = FL_tanh_range(i);
    [mse, mae, psnr, bits, img_out] = evaluate_config(config, IB_input, IB_weight, ...
        IB_bias, IB_acc, IB_act, IB_tanh, z_input, Wg2, bg2, Wg3, bg3, img_size, img_fp);
    results_individual.tanh(i) = struct('FL', FL_tanh_range(i), 'MSE', mse, ...
        'MAE', mae, 'PSNR', psnr, 'Bits', bits, 'Image', img_out);
end

%% 8. Strategy 2: Combined Configurations (Preset combinations)
fprintf('\n=== STRATEGY 2: Combined Configurations ===\n');

configs_combined = {};
configs_combined{1} = struct('name', 'Low Precision', 'input', 6, 'weight', 8, ...
    'bias', 8, 'acc', 10, 'act', 6, 'tanh', 8);
configs_combined{2} = struct('name', 'Medium Precision', 'input', 10, 'weight', 12, ...
    'bias', 10, 'acc', 14, 'act', 8, 'tanh', 10);
configs_combined{3} = struct('name', 'High Precision', 'input', 14, 'weight', 16, ...
    'bias', 14, 'acc', 18, 'act', 12, 'tanh', 14);
configs_combined{4} = struct('name', 'Weight-Focused', 'input', 8, 'weight', 16, ...
    'bias', 10, 'acc', 16, 'act', 8, 'tanh', 10);
configs_combined{5} = struct('name', 'Balanced Efficient', 'input', 8, 'weight', 12, ...
    'bias', 10, 'acc', 14, 'act', 8, 'tanh', 10);

results_combined = struct();
for i = 1:length(configs_combined)
    config = configs_combined{i};
    fprintf('Testing %s...\n', config.name);
    [mse, mae, psnr, bits, img_out] = evaluate_config(config, IB_input, IB_weight, ...
        IB_bias, IB_acc, IB_act, IB_tanh, z_input, Wg2, bg2, Wg3, bg3, img_size, img_fp);
    results_combined(i).name = config.name;
    results_combined(i).config = config;
    results_combined(i).MSE = mse;
    results_combined(i).MAE = mae;
    results_combined(i).PSNR = psnr;
    results_combined(i).Bits = bits;
    results_combined(i).Image = img_out;
end

%% 9. Visualisasi Individual Sweeps
figure('Position', [50 50 1600 1000]);

% Input FL sweep
subplot(3,2,1);
plot([results_individual.input.FL], [results_individual.input.MSE], '-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Fraction Length'); ylabel('MSE'); title('Input FL Impact');
grid on; set(gca, 'YScale', 'log');

% Weight FL sweep (PALING PENTING!)
subplot(3,2,2);
plot([results_individual.weight.FL], [results_individual.weight.MSE], '-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Fraction Length'); ylabel('MSE'); title('Weight FL Impact (CRITICAL)');
grid on; set(gca, 'YScale', 'log');

% Bias FL sweep
subplot(3,2,3);
plot([results_individual.bias.FL], [results_individual.bias.MSE], '-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Fraction Length'); ylabel('MSE'); title('Bias FL Impact');
grid on; set(gca, 'YScale', 'log');

% Accumulator FL sweep
subplot(3,2,4);
plot([results_individual.acc.FL], [results_individual.acc.MSE], '-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Fraction Length'); ylabel('MSE'); title('Accumulator FL Impact');
grid on; set(gca, 'YScale', 'log');

% Activation FL sweep
subplot(3,2,5);
plot([results_individual.act.FL], [results_individual.act.MSE], '-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Fraction Length'); ylabel('MSE'); title('Activation FL Impact');
grid on; set(gca, 'YScale', 'log');

% Tanh FL sweep
subplot(3,2,6);
plot([results_individual.tanh.FL], [results_individual.tanh.MSE], '-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Fraction Length'); ylabel('MSE'); title('Tanh FL Impact');
grid on; set(gca, 'YScale', 'log');

sgtitle('Individual Component FL Sweep - MSE Impact', 'FontSize', 14, 'FontWeight', 'bold');

%% 10. Visualisasi PSNR
figure('Position', [100 100 1600 1000]);

subplot(3,2,1);
plot([results_individual.input.FL], [results_individual.input.PSNR], '-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Fraction Length'); ylabel('PSNR (dB)'); title('Input FL vs PSNR');
grid on; yline(40, 'g--', 'Excellent'); yline(30, 'y--', 'Good');

subplot(3,2,2);
plot([results_individual.weight.FL], [results_individual.weight.PSNR], '-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Fraction Length'); ylabel('PSNR (dB)'); title('Weight FL vs PSNR (CRITICAL)');
grid on; yline(40, 'g--', 'Excellent'); yline(30, 'y--', 'Good');

subplot(3,2,3);
plot([results_individual.bias.FL], [results_individual.bias.PSNR], '-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Fraction Length'); ylabel('PSNR (dB)'); title('Bias FL vs PSNR');
grid on; yline(40, 'g--', 'Excellent'); yline(30, 'y--', 'Good');

subplot(3,2,4);
plot([results_individual.acc.FL], [results_individual.acc.PSNR], '-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Fraction Length'); ylabel('PSNR (dB)'); title('Accumulator FL vs PSNR');
grid on; yline(40, 'g--', 'Excellent'); yline(30, 'y--', 'Good');

subplot(3,2,5);
plot([results_individual.act.FL], [results_individual.act.PSNR], '-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Fraction Length'); ylabel('PSNR (dB)'); title('Activation FL vs PSNR');
grid on; yline(40, 'g--', 'Excellent'); yline(30, 'y--', 'Good');

subplot(3,2,6);
plot([results_individual.tanh.FL], [results_individual.tanh.PSNR], '-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Fraction Length'); ylabel('PSNR (dB)'); title('Tanh FL vs PSNR');
grid on; yline(40, 'g--', 'Excellent'); yline(30, 'y--', 'Good');

sgtitle('Individual Component FL Sweep - PSNR Analysis', 'FontSize', 14, 'FontWeight', 'bold');

%% 11. Visualisasi Bits vs MSE Trade-off
figure('Position', [150 150 1400 600]);

subplot(1,2,1);
% Individual best dari tiap sweep
hold on;
plot([results_individual.input.Bits], [results_individual.input.MSE], 'o-', 'DisplayName', 'Input', 'LineWidth', 1.5);
plot([results_individual.weight.Bits], [results_individual.weight.MSE], 's-', 'DisplayName', 'Weight', 'LineWidth', 1.5);
plot([results_individual.bias.Bits], [results_individual.bias.MSE], '^-', 'DisplayName', 'Bias', 'LineWidth', 1.5);
plot([results_individual.acc.Bits], [results_individual.acc.MSE], 'd-', 'DisplayName', 'Accumulator', 'LineWidth', 1.5);
plot([results_individual.act.Bits], [results_individual.act.MSE], 'v-', 'DisplayName', 'Activation', 'LineWidth', 1.5);
plot([results_individual.tanh.Bits], [results_individual.tanh.MSE], 'p-', 'DisplayName', 'Tanh', 'LineWidth', 1.5);
hold off;
xlabel('Total Bits'); ylabel('MSE'); title('Bits vs MSE Trade-off (Individual Sweeps)');
legend('Location', 'best'); grid on; set(gca, 'YScale', 'log');

subplot(1,2,2);
% Combined configs
scatter([results_combined.Bits], [results_combined.MSE], 150, 'filled');
xlabel('Total Bits'); ylabel('MSE'); title('Combined Configurations');
grid on; set(gca, 'YScale', 'log');
for i = 1:length(results_combined)
    text([results_combined(i).Bits]+50, [results_combined(i).MSE], ...
        results_combined(i).name, 'FontSize', 9);
end

sgtitle('Precision-Memory Trade-off Analysis', 'FontSize', 14, 'FontWeight', 'bold');

%% 12. Combined Configurations Comparison
figure('Position', [200 200 1400 500]);

subplot(1,3,1);
bar([results_combined.MSE]); set(gca, 'YScale', 'log');
set(gca, 'XTickLabel', {results_combined.name}, 'XTickLabelRotation', 45);
ylabel('MSE'); title('MSE Comparison'); grid on;

subplot(1,3,2);
bar([results_combined.PSNR]);
set(gca, 'XTickLabel', {results_combined.name}, 'XTickLabelRotation', 45);
ylabel('PSNR (dB)'); title('PSNR Comparison'); grid on;
yline(40, 'g--', 'Excellent'); yline(30, 'y--', 'Good');

subplot(1,3,3);
bar([results_combined.Bits]);
set(gca, 'XTickLabel', {results_combined.name}, 'XTickLabelRotation', 45);
ylabel('Total Bits'); title('Memory Footprint'); grid on;

sgtitle('Combined Configurations Comparison', 'FontSize', 14, 'FontWeight', 'bold');

%% 13. Summary Table
fprintf('\n\n=== INDIVIDUAL SWEEP SUMMARY ===\n');
fprintf('Best FL untuk setiap komponen (berdasarkan MSE):\n\n');

[~, idx] = min([results_individual.input.MSE]);
fprintf('Input:       FL=%2d → MSE=%.2e, PSNR=%.2f dB, WL=%2d (Q%d.%d)\n', ...
    results_individual.input(idx).FL, results_individual.input(idx).MSE, ...
    results_individual.input(idx).PSNR, IB_input+1+results_individual.input(idx).FL, ...
    IB_input, results_individual.input(idx).FL);

[~, idx] = min([results_individual.weight.MSE]);
fprintf('Weight:      FL=%2d → MSE=%.2e, PSNR=%.2f dB, WL=%2d (Q%d.%d) ⭐\n', ...
    results_individual.weight(idx).FL, results_individual.weight(idx).MSE, ...
    results_individual.weight(idx).PSNR, IB_weight+1+results_individual.weight(idx).FL, ...
    IB_weight, results_individual.weight(idx).FL);

[~, idx] = min([results_individual.bias.MSE]);
fprintf('Bias:        FL=%2d → MSE=%.2e, PSNR=%.2f dB, WL=%2d (Q%d.%d)\n', ...
    results_individual.bias(idx).FL, results_individual.bias(idx).MSE, ...
    results_individual.bias(idx).PSNR, IB_bias+1+results_individual.bias(idx).FL, ...
    IB_bias, results_individual.bias(idx).FL);

[~, idx] = min([results_individual.acc.MSE]);
fprintf('Accumulator: FL=%2d → MSE=%.2e, PSNR=%.2f dB, WL=%2d (Q%d.%d)\n', ...
    results_individual.acc(idx).FL, results_individual.acc(idx).MSE, ...
    results_individual.acc(idx).PSNR, IB_acc+1+results_individual.acc(idx).FL, ...
    IB_acc, results_individual.acc(idx).FL);

[~, idx] = min([results_individual.act.MSE]);
fprintf('Activation:  FL=%2d → MSE=%.2e, PSNR=%.2f dB, WL=%2d (Q%d.%d)\n', ...
    results_individual.act(idx).FL, results_individual.act(idx).MSE, ...
    results_individual.act(idx).PSNR, IB_act+1+results_individual.act(idx).FL, ...
    IB_act, results_individual.act(idx).FL);

[~, idx] = min([results_individual.tanh.MSE]);
fprintf('Tanh:        FL=%2d → MSE=%.2e, PSNR=%.2f dB, WL=%2d (Q%d.%d)\n', ...
    results_individual.tanh(idx).FL, results_individual.tanh(idx).MSE, ...
    results_individual.tanh(idx).PSNR, IB_tanh+1+results_individual.tanh(idx).FL, ...
    IB_tanh, results_individual.tanh(idx).FL);

fprintf('\n=== COMBINED CONFIGURATIONS SUMMARY ===\n');
fprintf('%-20s | %8s | %8s | %8s | %10s\n', 'Configuration', 'MSE', 'MAE', 'PSNR(dB)', 'TotalBits');
fprintf(repmat('-', 1, 70)); fprintf('\n');
for i = 1:length(results_combined)
    fprintf('%-20s | %.2e | %.2e | %8.2f | %10d\n', ...
        results_combined(i).name, results_combined(i).MSE, results_combined(i).MAE, ...
        results_combined(i).PSNR, results_combined(i).Bits);
end

[~, best_idx] = min([results_combined.MSE]);
fprintf('\n⭐ RECOMMENDED: %s\n', results_combined(best_idx).name);
fprintf('   MSE: %.6e | PSNR: %.2f dB | Total Bits: %d\n', ...
    results_combined(best_idx).MSE, results_combined(best_idx).PSNR, ...
    results_combined(best_idx).Bits);

%% =========================================================
%  FUNGSI PENDUKUNG
% =========================================================

function [mse, mae, psnr, total_bits, img_out] = evaluate_config(...
    FL_config, IB_input, IB_weight, IB_bias, IB_acc, IB_act, IB_tanh, ...
    z, Wg2, bg2, Wg3, bg3, img_size, img_fp)
    
    % Calculate word lengths (WL = IB + 1 (sign) + FL)
    WL_input = IB_input + 1 + FL_config.input;
    WL_weight = IB_weight + 1 + FL_config.weight;
    WL_bias = IB_bias + 1 + FL_config.bias;
    WL_acc = IB_acc + 1 + FL_config.acc;
    WL_act = IB_act + 1 + FL_config.act;
    WL_tanh = IB_tanh + 1 + FL_config.tanh;
    
    F = fimath('RoundingMethod','Nearest', 'OverflowAction','Saturate');
    
    % Convert inputs
    z_fx = fi(z, 1, WL_input, FL_config.input, 'fimath', F);
    
    % Convert weights dan biases
    Wg2_fx = fi(Wg2, 1, WL_weight, FL_config.weight, 'fimath', F);
    bg2_fx = fi(bg2, 1, WL_bias, FL_config.bias, 'fimath', F);
    Wg3_fx = fi(Wg3, 1, WL_weight, FL_config.weight, 'fimath', F);
    bg3_fx = fi(bg3, 1, WL_bias, FL_config.bias, 'fimath', F);
    
    % Layer 1: MAC dengan accumulator
    z2_acc = fi(zeros(size(bg2)), 1, WL_acc, FL_config.acc, 'fimath', F);
    for i = 1:size(Wg2, 1)
        for j = 1:size(Wg2, 2)
            z2_acc(i) = z2_acc(i) + Wg2_fx(i,j) * z_fx(j);
        end
        z2_acc(i) = z2_acc(i) + bg2_fx(i);
    end
    
    % Requantize ke activation precision
    z2_act = fi(zeros(size(z2_acc)), 1, WL_act, FL_config.act, 'fimath', F);
    for i = 1:length(z2_acc)
        z2_act(i) = fi(double(z2_acc(i)), 1, WL_act, FL_config.act, 'fimath', F);
    end
    
    % Tanh activation
    ag2_fx = fi(zeros(size(z2_act)), 1, WL_act, FL_config.act, 'fimath', F);
    for i = 1:length(z2_act)
        ag2_fx(i) = pwq_tanh_custom(z2_act(i), WL_tanh, FL_config.tanh, WL_act, FL_config.act);
    end
    
    % Layer 2: MAC
    z3_acc = fi(zeros(size(bg3)), 1, WL_acc, FL_config.acc, 'fimath', F);
    for i = 1:size(Wg3, 1)
        for j = 1:size(Wg3, 2)
            z3_acc(i) = z3_acc(i) + Wg3_fx(i,j) * ag2_fx(j);
        end
        z3_acc(i) = z3_acc(i) + bg3_fx(i);
    end
    
    % Requantize
    z3_act = fi(zeros(size(z3_acc)), 1, WL_act, FL_config.act, 'fimath', F);
    for i = 1:length(z3_acc)
        z3_act(i) = fi(double(z3_acc(i)), 1, WL_act, FL_config.act, 'fimath', F);
    end
    
    % Output activation
    x_fake_fx = fi(zeros(size(z3_act)), 1, WL_act, FL_config.act, 'fimath', F);
    for i = 1:length(z3_act)
        x_fake_fx(i) = pwq_tanh_custom(z3_act(i), WL_tanh, FL_config.tanh, WL_act, FL_config.act);
    end
    
    % Convert ke image
    img_out = double(reshape(double(x_fake_fx)/2 + 0.5, img_size, img_size)');
    
    % Calculate metrics
    mse = mean((img_out(:) - img_fp(:)).^2);
    mae = mean(abs(img_out(:) - img_fp(:)));
    psnr = 10*log10(1 / (mse + 1e-10));
    
    % Calculate total bits
    total_bits = length(z)*WL_input + numel(Wg2)*WL_weight + numel(bg2)*WL_bias + ...
                 numel(Wg3)*WL_weight + numel(bg3)*WL_bias + ...
                 numel(bg2)*WL_act + numel(bg3)*WL_act;
end

function y = pwq_tanh_custom(x, WL_tanh, FL_tanh, WL_out, FL_out)
    F = fimath('RoundingMethod','Nearest', 'OverflowAction','Saturate');
    x_fx = fi(double(x), 1, WL_tanh, FL_tanh, 'fimath', F);
    
    coeff = fi([
        -0.330005   1.101576  -0.006996
        -0.168637   0.699828   0.234964
        -0.012845   0.091424   0.836701
    ], 1, WL_tanh, FL_tanh, 'fimath', F);
    
    xi = abs(x_fx);
    s = sign(double(x_fx));
    if s == 0, s = 1; end
    
    if xi >= 4
        y_temp = 1;
    elseif xi >= 2
        p = coeff(3,:);
        y_temp = double(p(1)*xi*xi + p(2)*xi + p(3));
    elseif xi >= 1
        p = coeff(2,:);
        y_temp = double(p(1)*xi*xi + p(2)*xi + p(3));
    else
        p = coeff(1,:);
        y_temp = double(p(1)*xi*xi + p(2)*xi + p(3));
    end
    
    y_temp = s * y_temp;
    if y_temp > 1, y_temp = 1; end
    if y_temp < -1, y_temp = -1; end
    
    y = fi(y_temp, 1, WL_out, FL_out, 'fimath', F);
end