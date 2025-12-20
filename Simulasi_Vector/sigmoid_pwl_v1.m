% Perbandingan Sigmoid Asli vs PWL (Curvature Analysis - Zerun Li et al.)
x = -8:0.01:8;
y_true = 1 ./ (1 + exp(-x));

% --- Implementasi PWL Berdasarkan Analisis Kelengkungan ---
y_pwl = zeros(size(x));

for i = 1:length(x)
    xi = x(i);
    abs_x = abs(xi);
    
    % Kita hitung untuk sisi positif, lalu gunakan simetri
    if abs_x < 1
        % Area kelengkungan tinggi 1: y = 0.25x + 0.5
        val = 0.25 * abs_x + 0.5;
    elseif abs_x < 2.375
        % Area kelengkungan tinggi 2: y = 0.125x + 0.625
        val = 0.125 * abs_x + 0.625;
    elseif abs_x < 5
        % Area menuju saturasi: y = 0.03125x + 0.84375
        val = 0.03125 * abs_x + 0.84375;
    else
        % Area saturasi
        val = 1.0;
    end
    
    % Kembalikan ke sisi negatif jika perlu (Simetri)
    if xi < 0
        y_pwl(i) = 1 - val;
    else
        y_pwl(i) = val;
    end
end

% --- Plotting ---
% --- Window 1: Perbandingan Fungsi ---
figure('Color', 'w', 'Name', 'Perbandingan Fungsi Sigmoid');
plot(x, y_true, 'k', 'LineWidth', 2); hold on;
plot(x, y_pwl, 'r--', 'LineWidth', 1.5);
grid on; 
ylabel('Amplitude'); xlabel('Input x');
legend('Sigmoid Asli', 'PWL (Curvature Based)');
title('Perbandingan Sigmoid: Original vs PWL (Li et al.)');

% --- Window 2: Analisis Error ---
figure('Color', 'w', 'Name', 'Analisis Error Sigmoid');
plot(x, abs(y_true - y_pwl), 'b', 'LineWidth', 1.2);
grid on; 
ylabel('|Error|'); xlabel('Input x');
title(['Analisis Absolute Error (Max Error: ', num2str(max(abs(y_true - y_pwl))), ')']);