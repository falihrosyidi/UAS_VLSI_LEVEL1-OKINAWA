clear; clc;
x = linspace(-4, 4, 1000);
fl_range = 8:2:24; % Sweep FL dari 8 sampai 24
abs_err_sig = []; % Diubah dari mse_sig

for fl = fl_range
    WL = 8 + fl;
    F = fimath('RoundingMethod','Floor','OverflowAction','Saturate');
    y_hw = zeros(size(x));
    y_sig_ideal = 1 ./ (1 + exp(-x));
    
    for i = 1:length(x)
        ax = fi(abs(x(i)), 1, WL, fl, F);
        if ax < 1,         v = fi(0.25,1,WL,fl,F)*ax + fi(0.5,1,WL,fl,F);
        elseif ax < 2.375, v = fi(0.125,1,WL,fl,F)*ax + fi(0.625,1,WL,fl,F);
        elseif ax < 5,     v = fi(0.03125,1,WL,fl,F)*ax + fi(0.84375,1,WL,fl,F);
        else,              v = fi(1,1,WL,fl,F);
        end
        res = (x(i) < 0) * (1 - double(v)) + (x(i) >= 0) * double(v);
        y_hw(i) = res;
    end
    % Menghitung Mean Absolute Error (MAE)
    abs_err_sig = [abs_err_sig, mean(abs(y_sig_ideal - y_hw))]; 
end

figure('Name', 'Analisis Error Sigmoid');
plot(fl_range, abs_err_sig, '-s', 'Color', 'r', 'LineWidth', 2);
grid on; xlabel('Fractional Length (n)'); ylabel('Mean Absolute Error');
title('Absolute Error Sigmoid PWL vs Presisi (Q8.n)');