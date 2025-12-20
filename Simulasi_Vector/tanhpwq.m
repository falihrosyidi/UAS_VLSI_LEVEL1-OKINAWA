clear; clc;
% Konfigurasi Q8.24
FL = 24;
SCALE = 2^FL;

% Input yang diuji (termasuk nilai negatif)
test_inputs = [0,0.25,0.5,0.75, 1.0, 1.5, 2.5, 4.0, -0.5, -1.5, -5.0];

fprintf('========================================================\n');
fprintf('   HASIL REFERENSI PWQ TANH (Q8.24) - VERSI FIX\n');
fprintf('========================================================\n');
fprintf('%-10s | %-12s | %-10s\n', 'Input', 'Output (Dec)', 'Output (Hex)');
fprintf('--------------------------------------------------------\n');

for val = test_inputs
    % 1. Ambil nilai absolut (Symmetry)
    xi = abs(val);
    s = sign(val);
    
    % 2. Hitung Piecewise Quadratic (Sesuai formula Verilog)
    if xi >= 4
        y_abs = 1.0;
    elseif xi >= 2
        y_abs = -0.012845*xi*xi + 0.091424*xi + 0.836701;
    elseif xi >= 1
        y_abs = -0.168637*xi*xi + 0.699828*xi + 0.234964;
    else
        y_abs = -0.330005*xi*xi + 1.101576*xi - 0.006996;
    end
    
    % 3. Kembalikan tanda dan saturasi
    y_res = s * y_abs;
    if y_res > 1, y_res = 1; elseif y_res < -1, y_res = -1; end
    
    % 4. Konversi ke Fixed-Point (Integer)
    y_fixed = round(y_res * SCALE);
    
    % 5. PERBAIKAN: Konversi ke Hex 32-bit untuk bilangan negatif
    if y_fixed < 0
        % Teknik Two's Complement: Tambahkan 2^32 pada angka negatif
        y_hex = dec2hex(y_fixed + 4294967296, 8); 
    else
        y_hex = dec2hex(y_fixed, 8);
    end
    
    fprintf('%-10.2f | %-12.6f | %-10s\n', val, y_res, y_hex);
end
fprintf('========================================================\n');