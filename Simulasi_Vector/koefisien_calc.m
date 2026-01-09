% Calculator untuk konversi koefisien ke Q8.24 format
clear; clc;

fprintf('=== Q8.24 COEFFICIENT CALCULATOR ===\n\n');

% Fungsi konversi
function hex_str = decimal_to_q824_hex(dec_val)
    % Convert to Q8.24
    fixed_val = round(dec_val * 2^24);
    
    % Handle negative (two's complement)
    if fixed_val < 0
        fixed_val = 2^32 + fixed_val;
    end
    
    % Convert to hex
    hex_str = dec2hex(fixed_val, 8);
end

function dec_val = hex_to_q824_decimal(hex_str)
    val = hex2dec(hex_str);
    if val >= 2^31
        val = val - 2^32;  % Two's complement
    end
    dec_val = double(val) / 2^24;
end

% SIGMOID - Koefisien yang benar
fprintf('=== SIGMOID COEFFICIENTS ===\n\n');

fprintf('Segmen 1 [0.0-1.5]: y = (-0.036623)x^2 + (0.269097)x + (0.497822)\n');
% p1_seg1 = -0.036623;
% p2_seg1 = 0.269097;
% p3_seg1 = 0.497822;
p1_seg1 = -0.330005;
p2_seg1 = 1.101576;
p3_seg1 = -0.006996;
hex_p1_seg1 = decimal_to_q824_hex(p1_seg1);
hex_p2_seg1 = decimal_to_q824_hex(p2_seg1);
hex_p3_seg1 = decimal_to_q824_hex(p3_seg1);
fprintf('  p1 = %.6f -> 0x%s (verify: %.6f)\n', p1_seg1, hex_p1_seg1, hex_to_q824_decimal(hex_p1_seg1));
fprintf('  p2 = %.6f -> 0x%s (verify: %.6f)\n', p2_seg1, hex_p2_seg1, hex_to_q824_decimal(hex_p2_seg1));
fprintf('  p3 = %.6f -> 0x%s (verify: %.6f)\n', p3_seg1, hex_p3_seg1, hex_to_q824_decimal(hex_p3_seg1));
fprintf('  Verilog code:\n');
fprintf('    p1 = 32''h%s;\n', hex_p1_seg1);
fprintf('    p2 = 32''h%s;\n', hex_p2_seg1);
fprintf('    p3 = 32''h%s;\n\n', hex_p3_seg1);

fprintf('Segmen 2 [1.5-3.5]: y = (-0.029988)x^2 + (0.223978)x + (0.551643)\n');
% p1_seg2 = -0.029988;
% p2_seg2 = 0.223978;
% p3_seg2 = 0.551643;
p1_seg2 = -0.168637;
p2_seg2 = 0.699828;
p3_seg2 = 0.234964;
hex_p1_seg2 = decimal_to_q824_hex(p1_seg2);
hex_p2_seg2 = decimal_to_q824_hex(p2_seg2);
hex_p3_seg2 = decimal_to_q824_hex(p3_seg2);
fprintf('  p1 = %.6f -> 0x%s (verify: %.6f)\n', p1_seg2, hex_p1_seg2, hex_to_q824_decimal(hex_p1_seg2));
fprintf('  p2 = %.6f -> 0x%s (verify: %.6f)\n', p2_seg2, hex_p2_seg2, hex_to_q824_decimal(hex_p2_seg2));
fprintf('  p3 = %.6f -> 0x%s (verify: %.6f)\n', p3_seg2, hex_p3_seg2, hex_to_q824_decimal(hex_p3_seg2));
fprintf('  Verilog code:\n');
fprintf('    p1 = 32''h%s;\n', hex_p1_seg2);
fprintf('    p2 = 32''h%s;\n', hex_p2_seg2);
fprintf('    p3 = 32''h%s;\n\n', hex_p3_seg2);

fprintf('Segmen 3 [3.5-6.0]: y = (-0.004609)x^2 + (0.053606)x + (0.840844)\n');
% p1_seg3 = -0.004609;
% p2_seg3 = 0.053606;
% p3_seg3 = 0.840844;
p1_seg3 = -0.012845;
p2_seg3 = 0.091424;
p3_seg3 = 0.836701;
hex_p1_seg3 = decimal_to_q824_hex(p1_seg3);
hex_p2_seg3 = decimal_to_q824_hex(p2_seg3);
hex_p3_seg3 = decimal_to_q824_hex(p3_seg3);
fprintf('  p1 = %.6f -> 0x%s (verify: %.6f)\n', p1_seg3, hex_p1_seg3, hex_to_q824_decimal(hex_p1_seg3));
fprintf('  p2 = %.6f -> 0x%s (verify: %.6f)\n', p2_seg3, hex_p2_seg3, hex_to_q824_decimal(hex_p2_seg3));
fprintf('  p3 = %.6f -> 0x%s (verify: %.6f)\n', p3_seg3, hex_p3_seg3, hex_to_q824_decimal(hex_p3_seg3));
fprintf('  Verilog code:\n');
fprintf('    p1 = 32''h%s;\n', hex_p1_seg3);
fprintf('    p2 = 32''h%s;\n', hex_p2_seg3);
fprintf('    p3 = 32''h%s;\n\n', hex_p3_seg3);

% Bandingkan dengan nilai di Verilog saat ini
fprintf('\n=== COMPARISON WITH CURRENT VERILOG VALUES ===\n\n');
fprintf('Segment 1:\n');
fprintf('  Current p1: 0xFFFA1546 = %.6f\n', hex_to_q824_decimal('FFFA1546'));
fprintf('  Correct p1: 0x%s = %.6f\n', hex_p1_seg1, hex_to_q824_decimal(hex_p1_seg1));
fprintf('  Difference: %.6f\n\n', abs(hex_to_q824_decimal('FFFA1546') - p1_seg1));

fprintf('Segment 2:\n');
fprintf('  Current p1: 0xFFFB337E = %.6f\n', hex_to_q824_decimal('FFFB337E'));
fprintf('  Correct p1: 0x%s = %.6f\n', hex_p1_seg2, hex_to_q824_decimal(hex_p1_seg2));
fprintf('  Difference: %.6f\n\n', abs(hex_to_q824_decimal('FFFB337E') - p1_seg2));

fprintf('Segment 3:\n');
fprintf('  Current p1: 0xFFFF2E17 = %.6f\n', hex_to_q824_decimal('FFFF2E17'));
fprintf('  Correct p1: 0x%s = %.6f\n', hex_p1_seg3, hex_to_q824_decimal(hex_p1_seg3));
fprintf('  Difference: %.6f\n\n', abs(hex_to_q824_decimal('FFFF2E17') - p1_seg3));

fprintf('=== CORRECTED VERILOG CODE ===\n\n');
fprintf('    // Segment 1 [0.0, 1.5)\n');
fprintf('    p1 = 32''h%s;  // %.6f\n', hex_p1_seg1, p1_seg1);
fprintf('    p2 = 32''h%s;  // %.6f\n', hex_p2_seg1, p2_seg1);
fprintf('    p3 = 32''h%s;  // %.6f\n\n', hex_p3_seg1, p3_seg1);

fprintf('    // Segment 2 [1.5, 3.5)\n');
fprintf('    p1 = 32''h%s;  // %.6f\n', hex_p1_seg2, p1_seg2);
fprintf('    p2 = 32''h%s;  // %.6f\n', hex_p2_seg2, p2_seg2);
fprintf('    p3 = 32''h%s;  // %.6f\n\n', hex_p3_seg2, p3_seg2);

fprintf('    // Segment 3 [3.5, 6.0)\n');
fprintf('    p1 = 32''h%s;  // %.6f\n', hex_p1_seg3, p1_seg3);
fprintf('    p2 = 32''h%s;  // %.6f\n', hex_p2_seg3, p2_seg3);
fprintf('    p3 = 32''h%s;  // %.6f\n', hex_p3_seg3, p3_seg3);