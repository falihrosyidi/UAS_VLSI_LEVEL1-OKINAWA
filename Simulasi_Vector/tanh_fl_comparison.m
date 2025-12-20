clear; clc;
x = linspace(-4, 4, 1000);
y_ideal = tanh(x);
fl_range = 8:2:24; 
abs_err_tanh = []; % Diubah dari mse_tanh

for fl = fl_range
    WL = 8 + fl; 
    F = fimath('RoundingMethod','Floor','OverflowAction','Saturate');
    
    coeff = fi([-0.330005, 1.101576, -0.006996; ... 
                 -0.168637, 0.699828, 0.234964; ... 
                 -0.012845, 0.091424, 0.836701], 1, WL, fl, F);
    
    y_hw = zeros(size(x));
    for i = 1:length(x)
        xi = fi(abs(x(i)), 1, WL, fl, F);
        if xi >= 4, v = fi(1,1,WL,fl,F);
        elseif xi >= 2, p = coeff(3,:); v = p(1)*xi*xi + p(2)*xi + p(3);
        elseif xi >= 1, p = coeff(2,:); v = p(1)*xi*xi + p(2)*xi + p(3);
        else,           p = coeff(1,:); v = p(1)*xi*xi + p(2)*xi + p(3);
        end
        y_hw(i) = sign(x(i)) * double(v);
    end
    % Menghitung Mean Absolute Error (MAE)
    abs_err_tanh = [abs_err_tanh, mean(abs(y_ideal - y_hw))];
end

figure('Name', 'Analisis Error Tanh');
plot(fl_range, abs_err_tanh, '-o', 'LineWidth', 2);
grid on; xlabel('Fractional Length (n)'); ylabel('Mean Absolute Error');
title('Absolute Error Tanh PWQ vs Presisi (Q8.n)');