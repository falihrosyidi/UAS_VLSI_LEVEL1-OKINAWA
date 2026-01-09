clc; clear;

%% Fixed-point format
WL = 32;        % word length
FL = 24;        % fractional length (Q4.12)
F  = fimath('RoundingMethod','Nearest',...
            'OverflowAction','Saturate');

%% Domain
x = linspace(-4,4,5000);
y_true = tanh(x);

%% Breakpoints
bp = [0 1 2 4];

%% Fit quadratic for positive side
coeff = zeros(3,3); % [a b c] per segment

for k = 1:3
    xs = linspace(bp(k), bp(k+1), 200);
    ys = tanh(xs);
    p = polyfit(xs, ys, 2);
    fprintf('Segmen %d: y = %.6f x^2 + %.6f x + %.6f\n', ...
        k, p(1), p(2), p(3));
    coeff(k,:) = p;
end

%% Quantize coefficients
coeff_fx = fi(coeff, 1, WL, FL, 'fimath', F);

%% Piecewise approximation
y_apx = zeros(size(x));

for n = 1:length(x)
    xi = abs(x(n));
    s  = sign(x(n));

    if xi >= 4
        y_apx(n) = s*1;
    elseif xi >= 2
        p = coeff_fx(3,:);
        y_apx(n) = s*(p(1)*xi^2 + p(2)*xi + p(3));
    elseif xi >= 1
        p = coeff_fx(2,:);
        y_apx(n) = s*(p(1)*xi^2 + p(2)*xi + p(3));
    else
        p = coeff_fx(1,:);
        y_apx(n) = s*(p(1)*xi^2 + p(2)*xi + p(3));
    end
end

%% Plot
figure;
plot(x, y_true, 'k', 'LineWidth', 2); hold on;
plot(x, y_apx, '--r', 'LineWidth', 1.5);
grid on;
legend('tanh(x)', 'Piecewise Quadratic (fixed)');
title('tanh vs Piecewise Quadratic Approximation');

%% Error
figure;
plot(x, y_true - y_apx);
grid on;
title('Approximation Error');
ylabel('Error');
xlabel('x');

fprintf('Max abs error = %.5f\n', max(abs(y_true - y_apx)));
