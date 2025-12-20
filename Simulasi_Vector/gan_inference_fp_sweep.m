clear; clc;

%% Load trained weights
load('trained_simple_gan.mat', 'Wg2', 'bg2', 'Wg3', 'bg3');

%% Sweep parameters
WL = 16;
FL_list = 8:14;

fprintf('FL\tMaxAbsError\n');
fprintf('-------------------\n');

for FL = FL_list

    %% Shared fimath (WAJIB sama semua)
    F = fimath( ...
        'RoundingMethod','Nearest', ...
        'OverflowAction','Saturate', ...
        'ProductMode','SpecifyPrecision', ...
        'ProductWordLength',WL, ...
        'ProductFractionLength',FL, ...
        'SumMode','SpecifyPrecision', ...
        'SumWordLength',WL, ...
        'SumFractionLength',FL );

    %% Convert everything to fixed-point
    W2_fx = fi(Wg2, 1, WL, FL, 'fimath', F);
    b2_fx = fi(bg2, 1, WL, FL, 'fimath', F);
    W3_fx = fi(Wg3, 1, WL, FL, 'fimath', F);
    b3_fx = fi(bg3, 1, WL, FL, 'fimath', F);

    z_fx  = fi([0; 1], 1, WL, FL, 'fimath', F);

    %% ===== Floating reference =====
    z2_f = Wg2 * double(z_fx) + bg2;
    a2_f = tanh(z2_f);
    z3_f = Wg3 * a2_f + bg3;
    y_f  = tanh(z3_f);

    %% ===== Fixed-point inference =====
    z2 = W2_fx * z_fx + b2_fx;

    a2 = arrayfun(@(x) pwq_tanh_fixed(x, WL, FL, F), z2);

    z3 = W3_fx * a2 + b3_fx;

    y_fx = arrayfun(@(x) pwq_tanh_fixed(x, WL, FL, F), z3);

    %% Error
    err = max(abs(double(y_fx) - y_f));
    fprintf('%d\t%.6f\n', FL, err);
end

function y = pwq_tanh_fixed(x, WL, FL, F)

    x = fi(x, 1, WL, FL, 'fimath', F);

    coeff = fi([
        -0.330005   1.101576  -0.006996
        -0.168637   0.699828   0.234964
        -0.012845   0.091424   0.836701
    ], 1, WL, FL, 'fimath', F);

    xi = abs(x);
    s  = sign(x);

    if xi >= 4
        y = s * fi(1,1,WL,FL,'fimath',F);
    elseif xi >= 2
        p = coeff(3,:);
        y = s*(p(1)*xi*xi + p(2)*xi + p(3));
    elseif xi >= 1
        p = coeff(2,:);
        y = s*(p(1)*xi*xi + p(2)*xi + p(3));
    else
        p = coeff(1,:);
        y = s*(p(1)*xi*xi + p(2)*xi + p(3));
    end

    % final saturation
    if y > 1
        y = fi(1,1,WL,FL,'fimath',F);
    elseif y < -1
        y = fi(-1,1,WL,FL,'fimath',F);
    end
end
