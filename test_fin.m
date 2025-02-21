clc;
clear;
close all;

% 基本参数设置
fs = 200;                % 采样频率
t = 0:1/fs:1-1/fs;       % 时间序列 (1秒，避免多余采样点)
N1 = 40; N2 = 64; N3 = 128; % 不同点数的 FFT
f = linspace(0, fs/2, max([N1, N2, N3])/2 + 1); % 最大频率轴

% 构造信号
x = 0.5 * sin(2*pi*10*t) + 2 * cos(2*pi*40*t);

% **真实谱计算：手动构造离散谱**
X_true = zeros(size(f));            % 初始化为零
[~, idx10] = min(abs(f - 10));      % 找到离 10 Hz 最近的索引
[~, idx40] = min(abs(f - 40));      % 找到离 40 Hz 最近的索引
X_true(idx10) = 0.5;                % 对应 10 Hz，幅值为 0.5
X_true(idx40) = 2;                % 对应 40 Hz，幅值为 0.2

% 绘制信号与真实频谱
figure;

% 40 点 FFT
subplot(3, 1, 1);
f_N1 = linspace(0, fs/2, N1/2 + 1); % 40点 FFT 的频率轴
X1 = abs(fft(x, N1)) / length(x);   % 40点 FFT 归一化幅值
stem(f, 2*X_true, 'k', 'LineWidth', 1.5, 'DisplayName', '真实频谱'); hold on;
stem(f_N1, 2*X1(1:N1/2+1), '-o', 'DisplayName', '40点 FFT');
title('40 点 FFT 对比真实频谱');
xlabel('频率 (Hz)');
ylabel('幅值');
legend;
grid on;

% 64 点 FFT
subplot(3, 1, 2);
f_N2 = linspace(0, fs/2, N2/2 + 1); % 64点 FFT 的频率轴
X2 = abs(fft(x, N2)) / length(x);   % 64点 FFT 归一化幅值
stem(f, 2*X_true, 'k', 'LineWidth', 1.5, 'DisplayName', '真实频谱'); hold on;
stem(f_N2, 2*X2(1:N2/2+1), '-o', 'DisplayName', '64点 FFT');
title('64 点 FFT 对比真实频谱');
xlabel('频率 (Hz)');
ylabel('幅值');
legend;
grid on;

% 128 点 FFT
subplot(3, 1, 3);
f_N3 = linspace(0, fs/2, N3/2 + 1); % 128点 FFT 的频率轴
X3 = abs(fft(x, N3)) / length(x);   % 128点 FFT 归一化幅值
stem(f, 2*X_true, 'k', 'LineWidth', 1.5, 'DisplayName', '真实频谱'); hold on;
stem(f_N3, 2*X3(1:N3/2+1), '-o', 'DisplayName', '128点 FFT');
title('128 点 FFT 对比真实频谱');
xlabel('频率 (Hz)');
ylabel('幅值');
legend;
grid on;
