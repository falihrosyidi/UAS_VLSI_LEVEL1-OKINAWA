clc; clear;

%% Domain & Target
x_full = linspace(-6, 6, 5000);
y_true = 1 ./ (1 + exp(-x_full));

%% Config - 3 Segmen
% Breakpoint dioptimalkan untuk presisi tinggi
bp = [0 1.5 3.5 6.0]; 
num_segments = length(bp) - 1;

coeff_final = zeros(num_segments, 3);
fprintf('Menghitung koefisien Full Precision (3 Segmen)...\n');

for k = 1:num_segments
    % Ambil data pada rentang segmen
    xs = linspace(bp(k), bp(k+1), 1000);
    ys = 1 ./ (1 + exp(-xs));
    
    % Fit parabola y = ax^2 + bx + c
    p = polyfit(xs, ys, 2);
    coeff_final(k,:) = p;
    
    fprintf('Segmen %d [%.1f-%.1f]: y = (%.6f)x^2 + (%.6f)x + (%.6f)\n', ...
        k, bp(k), bp(k+1), p(1), p(2), p(3));
end

%% Piecewise Reconstruction
y_apx = zeros(size(x_full));
for n = 1:length(x_full)
    xi = abs(x_full(n));
    
    if xi >= bp(end)
        val = 1;
    else
        % Pilih segmen berdasarkan xi
        idx = find(xi < bp, 1) - 1;
        if isempty(idx), idx = num_segments; end
        
        p = coeff_final(idx,:);
        % Kalkulasi full multiplier: y = ax^2 + bx + c
        val = p(1)*xi^2 + p(2)*xi + p(3);
    end
    
    % Terapkan simetri sigmoid: f(-x) = 1 - f(x)
    if x_full(n) < 0
        y_apx(n) = 1 - val;
    else
        y_apx(n) = val;
    end
end

max_err = max(abs(y_true - y_apx));
fprintf('\nMax abs error (Full Precision 3-Seg) = %.6f\n', max_err);

%% Plotting
figure('Color', 'w');
subplot(2,1,1);
plot(x_full, y_true, 'k', 'LineWidth', 2); hold on;
plot(x_full, y_apx, '--r', 'LineWidth', 1.5);
grid on; title('Sigmoid: 3-Segment Full Precision');
legend('True Sigmoid', 'Piecewise Quadratic');

subplot(2,1,2);
plot(x_full, y_true - y_apx, 'g');
grid on; title(['Error Profile (Max Error: ', num2str(max_err), ')']);
ylabel('Error');