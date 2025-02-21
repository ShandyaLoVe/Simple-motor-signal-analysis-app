% 读取数据
[fileName, filePath] = uigetfile({'*.xlsx;*.csv;*.txt', 'Supported Files (*.xlsx, *.csv, *.txt)'}, '选择信号文件');
if fileName == 0
    error('未选择文件');
end
data = readtable(fullfile(filePath, fileName));

% 提取数据
time = data.Time_in_s;
excitation = data.Excitation_force_signal;
acceleration = data.Vibration_acceleration_signal;

% 频谱分析
Fs = 1 / mean(diff(time)); % 计算采样频率
N = length(time); % 信号长度
f = (0:N-1) * (Fs / N); % 频率轴
Excitation_spectrum = abs(fft(excitation)); % 激励信号的频谱
Acceleration_spectrum = abs(fft(acceleration)); % 响应信号的频谱

% 绘制频谱
figure;
subplot(2,1,1);
plot(f, Excitation_spectrum);
title('激励信号频谱');
xlabel('频率 (Hz)');
ylabel('幅度');

subplot(2,1,2);
plot(f, Acceleration_spectrum);
title('响应信号频谱');
xlabel('频率 (Hz)');
ylabel('幅度');

% 功率谱分析
[pxx_ex, f_ex] = pwelch(excitation, [], [], [], Fs);
[pxx_acc, f_acc] = pwelch(acceleration, [], [], [], Fs);

% 绘制功率谱
figure;
subplot(2,1,1);
semilogx(f_ex, 10*log10(pxx_ex));
title('激励信号功率谱');
xlabel('频率 (Hz)');
ylabel('功率谱 (dB/Hz)');

subplot(2,1,2);
semilogx(f_acc, 10*log10(pxx_acc));
title('响应信号功率谱');
xlabel('频率 (Hz)');
ylabel('功率谱 (dB/Hz)');

% 自相关分析
auto_corr_excitation = xcorr(excitation, 'biased');
auto_corr_acceleration = xcorr(acceleration, 'biased');

% 绘制自相关函数
figure;
subplot(2,1,1);
plot(auto_corr_excitation);
title('激励信号自相关');
xlabel('时延 (s)');
ylabel('自相关');

subplot(2,1,2);
plot(auto_corr_acceleration);
title('响应信号自相关');
xlabel('时延 (s)');
ylabel('自相关');

% 互相关分析
cross_corr = xcorr(excitation, acceleration, 'biased');

% 绘制互相关函数
figure;
plot(cross_corr);
title('激励信号与响应信号互相关');
xlabel('时延 (s)');
ylabel('互相关');

% A计权声压级
[a_weighted, f] = aWeighting(f, pxx_acc); % 使用pwelch计算的功率谱
L_A = 10 * log10(sum(a_weighted)); % A计权声压级 (dB)

% 显示A计权声压级
disp(['A计权声压级：', num2str(L_A), ' dB']);

% 1/3倍频程分析
thirdOctaveBands = octaveFilterBank(Fs, 1/3, f_acc); % 使用1/3倍频程滤波器
figure;
semilogx(f_acc, 10*log10(thirdOctaveBands));
title('1/3倍频程分析');
xlabel('频率 (Hz)');
ylabel('功率 (dB)');

% 计算声品质客观评价（响度、粗糙度、尖锐度、波动度等）
loudness = loudnessCalculation(pxx_acc, Fs);
roughness = roughnessCalculation(pxx_acc, Fs);
sharpness = sharpnessCalculation(pxx_acc, Fs);
fluctuation = fluctuationCalculation(pxx_acc, Fs);

disp(['响度：', num2str(loudness)]);
disp(['粗糙度：', num2str(roughness)]);
disp(['尖锐度：', num2str(sharpness)]);
disp(['波动度：', num2str(fluctuation)]);

%% 以下是自定义的函数部分，计算响度、粗糙度、尖锐度和波动度

function loudness = loudnessCalculation(pxx, Fs)
    % 实现响度计算方法
    % 此处使用的是一个简单的响度模型，具体可以基于ISO标准进行更详细的计算
    loudness = sum(10 * log10(pxx)) / length(pxx); % 简单示例
end

function roughness = roughnessCalculation(pxx, Fs)
    % 实现粗糙度计算
    roughness = sum(pxx .* (1:length(pxx))'); % 粗糙度的计算方法
end

function sharpness = sharpnessCalculation(pxx, Fs)
    % 实现尖锐度计算
    sharpness = sum(pxx .* log(1 + (1:length(pxx))')) / sum(pxx); % 简单示例
end

function fluctuation = fluctuationCalculation(pxx, Fs)
    % 实现波动度计算
    fluctuation = std(pxx) / mean(pxx); % 波动度的计算
end

function [a_weighted, f] = aWeighting(frequency, pxx)
    % A计权函数
    % A计权滤波器的设计参数
    A_Weighting_Factor = (12194^2 * frequency.^4) ./ ((frequency.^2 + 20.6^2) .* sqrt((frequency.^2 + 107.7^2) .* (frequency.^2 + 737.9^2)) .* (frequency.^2 + 12194^2));
    a_weighted = pxx .* A_Weighting_Factor;
end

function thirdOctaveBands = octaveFilterBank(Fs, fraction, f)
    % 1/3倍频程滤波器
    bandWidth = 1 / 3; % 1/3倍频程
    fmin = 20; % 最小频率
    fmax = Fs / 2; % 最大频率
    fCenters = 2.^(0:bandWidth:log2(fmax/fmin));
    thirdOctaveBands = zeros(length(f), length(fCenters));
    
    for i = 1:length(fCenters)
        band = (f >= fCenters(i)/sqrt(2)) & (f <= fCenters(i)*sqrt(2));
        thirdOctaveBands(:, i) = band .* pwelch(f);
    end
end
