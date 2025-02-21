clc;
clear;
close all;

% 选择 Excel 文件
[excelFile, filePath] = uigetfile('*.xlsx', '选择数据文件');
if isequal(excelFile, 0)
error('未选择文件，请重新运行并选择文件');
end
fullPath = fullfile(filePath, excelFile);

% 读取 Excel 数据
try
data = readtable(fullPath); % 默认读取第一个工作表
time = data.Time_seconds; % 时间数据
soundPressure = data.Sound_pressure_PASCAL; % 声压数据
catch ME
error('读取Excel数据时出错: %s', ME.message);
end

% 检查数据
if isempty(time) || isempty(soundPressure)
error('时间或声压列数据为空，请检查Excel文件内容。');
end

% 计算采样率
dt = mean(diff(time)); % 时间间隔
fs = 1 / dt; % 采样率 (Hz)

% FFT 计算
N = length(soundPressure); % 数据点数
Y = fft(soundPressure); % 快速傅里叶变换
f = (0:N-1) * (fs / N); % 频率向量
Y_magnitude = abs(Y) / N; % 归一化幅值

% 功率谱密度计算
PSD = (Y_magnitude.^2) * (fs / N); % 功率谱密度

% 只保留正频率部分
f_half = f(1:floor(N/2)+1);
Y_half = Y_magnitude(1:floor(N/2)+1);
PSD_half = PSD(1:floor(N/2)+1);

% 绘制图像
figure;

% 时域图
subplot(3, 1, 1);
plot(time, soundPressure, 'b-', 'LineWidth', 1.5);
grid on;
title('信号时域图');
xlabel('时间 (s)');
ylabel('声压 (Pa)');
xlim([min(time), max(time)]);

% 频谱图
subplot(3, 1, 2);
plot(f_half, Y_half, 'r-', 'LineWidth', 1.5);
grid on;
title('信号频谱图');
xlabel('频率 (Hz)');
ylabel('归一化幅值');
xlim([0, fs/2]); % 频率范围限制在 Nyquist 频率内

% 功率谱密度图
subplot(3, 1, 3);
plot(f_half, 10*log10(PSD_half), 'g-', 'LineWidth', 1.5);
grid on;
title('功率谱密度 (PSD)');
xlabel('频率 (Hz)');
ylabel('功率谱密度 (dB/Hz)');
xlim([0, fs/2]); % 频率范围限制在 Nyquist 频率内

% 调整整体布局
sgtitle('信号时域、频谱及功率谱密度分析');