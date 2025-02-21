clc;
clear;
close all;

% 文件路径设置
[filename, filepath] = uigetfile('*.xlsx', '选择数据文件');
if isequal(filename, 0)
    error('未选择文件，请重新运行并选择文件');
end
fullpath = fullfile(filepath, filename);

% 读取 Excel 数据
data = readtable(fullpath);
time = data.Time_seconds;  % 时间 (秒)
pressure = data.Sound_pressure_PASCAL;  % 声压 (帕斯卡)

% 采样率 (根据你的数据进行修改)
fs = 44100; % 假设采样率为44100 Hz

% 计算频率
N = length(pressure);
f = (0:N-1)*(fs/N);

% A 计权函数
Ra = @(f) (12194^2 * f.^4) ./ ((f.^2 + 20.6^2) .* sqrt((f.^2 + 107.7^2) .* (f.^2 + 737.9^2)) .* (f.^2 + 12194^2));
A = @(f) 20*log10(Ra(f)) - 20*log10(Ra(1000));

% B 计权函数
Rb = @(f) (12194^2 * f.^3) ./ ((f.^2 + 20.6^2) .* sqrt((f.^2 + 158.5^2)) .* (f.^2 + 12194^2));
B = @(f) 20*log10(Rb(f)) - 20*log10(Rb(1000));

% C 计权函数
Rc = @(f) (12194^2 * f.^2) ./ ((f.^2 + 20.6^2) .* (f.^2 + 12194^2));
C = @(f) 20*log10(Rc(f)) - 20*log10(Rc(1000));

% D 计权函数
h = @(f) ((1037918.48 - f.^2).^2 + 1080768.16 * f.^2) ./ ((9837328 - f.^2).^2 + 11723776 * f.^2);
Rd = @(f) f ./ (6.8966888496476 * 10^-5 * sqrt(h(f) .* ((f.^2 + 79919.29) .* (f.^2 + 1345600))));
D = @(f) 20*log10(Rd(f));

% 计算 FFT
P = fft(pressure);

% 计算各计权声压级
Pa = P .* (10.^(A(f')/20));
Pb = P .* (10.^(B(f')/20));
Pc = P .* (10.^(C(f')/20));
Pd = P .* (10.^(D(f')/20));

% 计算各计权声压
pressure_A = ifft(Pa);
pressure_B = ifft(Pb);
pressure_C = ifft(Pc);
pressure_D = ifft(Pd);

% 绘图
figure;

subplot(4,2,1);
plot(time, real(pressure_A)); % 使用 real() 函数
title('A-weighted Sound Pressure');
xlabel('Time (s)');
ylabel('Pressure (Pa)');
grid on;

subplot(4,2,3);
plot(time, real(pressure_B)); % 使用 real() 函数
title('B-weighted Sound Pressure');
xlabel('Time (s)');
ylabel('Pressure (Pa)');
grid on;

subplot(4,2,5);
plot(time, real(pressure_C)); % 使用 real() 函数
title('C-weighted Sound Pressure');
xlabel('Time (s)');
ylabel('Pressure (Pa)');
grid on;

subplot(4,2,7);
plot(time, real(pressure_D)); % 使用 real() 函数
title('D-weighted Sound Pressure');
xlabel('Time (s)');
ylabel('Pressure (Pa)');
grid on;

% 计算并绘制频谱
Lp_A = 20*log10(abs(Pa)/(2e-5)); % A-weighted SPL
Lp_B = 20*log10(abs(Pb)/(2e-5)); % B-weighted SPL
Lp_C = 20*log10(abs(Pc)/(2e-5)); % C-weighted SPL
Lp_D = 20*log10(abs(Pd)/(2e-5)); % D-weighted SPL

% 绘制频谱 (只绘制正频率部分)
f_half = f(1:round(N/2+1));

subplot(4,2,2);
plot(f_half, Lp_A(1:round(N/2+1)));
title('A-weighted Sound Pressure Level');
xlabel('Frequency (Hz)');
ylabel('SPL (dB)');
grid on;

subplot(4,2,4);
plot(f_half, Lp_B(1:round(N/2+1)));
title('B-weighted Sound Pressure Level');
xlabel('Frequency (Hz)');
ylabel('SPL (dB)');
grid on;

subplot(4,2,6);
plot(f_half, Lp_C(1:round(N/2+1)));
title('C-weighted Sound Pressure Level');
xlabel('Frequency (Hz)');
ylabel('SPL (dB)');
grid on;

subplot(4,2,8);
plot(f_half, Lp_D(1:round(N/2+1)));
title('D-weighted Sound Pressure Level');
xlabel('Frequency (Hz)');
ylabel('SPL (dB)');
grid on;

% 输出结果 (例如，将结果保存到新的 Excel 文件)
% 使用较短的长度
len = round(N/2 + 1);

% 截断 time 和 pressure_X
time_truncated = time(1:len);
pressure_A_truncated = real(pressure_A(1:len));
pressure_B_truncated = real(pressure_B(1:len));
pressure_C_truncated = real(pressure_C(1:len));
pressure_D_truncated = real(pressure_D(1:len));

output_data = table(time_truncated, pressure_A_truncated, pressure_B_truncated, pressure_C_truncated, pressure_D_truncated, f_half', Lp_A(1:len), Lp_B(1:len), Lp_C(1:len), Lp_D(1:len), ...
    'VariableNames', {'Time_seconds', 'Pressure_A_Pa', 'Pressure_B_Pa', 'Pressure_C_Pa', 'Pressure_D_Pa', 'Frequency_Hz', 'SPL_A_dB', 'SPL_B_dB', 'SPL_C_dB', 'SPL_D_dB'});
writetable(output_data, 'output_data.xlsx');

% 调整子图间距
sgtitle('Sound Pressure and Level Analysis')