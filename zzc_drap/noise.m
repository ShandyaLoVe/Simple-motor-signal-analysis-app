% % clc;
% % clear;
% % close all;
% % 
% % %% 参数设置
% % excelFile = '50rpm.xlsx';
% % sheetName = 1;
% % timeColumn = 'Time_seconds';
% % soundPressureColumn = 'Sound_pressure_PASCAL';
% % 
% % %% 数据读取
% % data = readtable(excelFile, 'Sheet', sheetName);
% % time = data.(timeColumn);
% % soundPressure = data.(soundPressureColumn);
% % time = time(:);
% % soundPressure = soundPressure(:);
% % 
% % %% 绘制原始噪声信号时域图
% % figure;
% % plot(time, soundPressure, 'b', 'LineWidth', 1.5);
% % xlabel('Time (s)');
% % ylabel('Sound Pressure (Pa)');
% % title('Noise Signal in Time Domain');
% % grid on;
% % 
% % %% 下采样
% % downsampleFactor = 10;
% % timeDownsampled = downsample(time, downsampleFactor);
% % soundPressureDownsampled = downsample(soundPressure, downsampleFactor);
% % 
% % % 显示下采样后的数据
% % disp(['原始数据点数: ', num2str(length(time))]);
% % disp(['下采样后数据点数: ', num2str(length(timeDownsampled))]);
% % 
% % %% 频谱分析
% % Fs = 1 / mean(diff(timeDownsampled));
% % L = length(soundPressureDownsampled);
% % f = Fs * (0:(L/2)) / L;
% % Y = fft(soundPressureDownsampled);
% % P2 = abs(Y / L);
% % P1 = P2(1:L/2+1);
% % P1(2:end-1) = 2*P1(2:end-1);
% % 
% % % 绘制频谱图
% % figure;
% % plot(f, P1, 'r', 'LineWidth', 1.5);
% % xlabel('Frequency (Hz)');
% % ylabel('Amplitude');
% % title('Noise Signal Spectrum (Downsampled)');
% % grid on;
% % 
% % %% 功率谱分析
% % powerSpectrum = P1.^2;
% % figure;
% % plot(f, 10*log10(powerSpectrum), 'g', 'LineWidth', 1.5);
% % xlabel('Frequency (Hz)');
% % ylabel('Power/Frequency (dB/Hz)');
% % title('Power Spectrum of Noise Signal (Downsampled)');
% % grid on;
% % 
% % %% 自相关分析
% % [autocorr, lag] = xcorr(soundPressureDownsampled, 'coeff');
% % lagTime = lag / Fs;
% % figure;
% % plot(lagTime, autocorr, 'b', 'LineWidth', 1.5);
% % xlabel('Lag Time (s)');
% % ylabel('Autocorrelation');
% % title('Autocorrelation of Noise Signal (Downsampled)');
% % grid on;
% % 
% % %% 倍频程分析和绘图函数
% % function plotFractionalOctave(powerSpectrum, f, fraction, name)
% %     % 定义中心频率和上下边界
% %     switch fraction
% %         case 1
% %             centerFreqs = [31.5, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000];
% %             lowerBounds = centerFreqs ./ sqrt(2);
% %             upperBounds = centerFreqs .* sqrt(2);
% %         case 2
% %             centerFreqs = [31.5, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000];
% %             lowerBounds = centerFreqs ./ 2;
% %             upperBounds = centerFreqs .* 2;
% %         case 1/3
% %             centerFreqs = [12.5, 16, 20, 25, 31.5, 40, 50, 63, 80, 100, 125, 160, 200, 250, 315, 400, 500, 630, 800, 1000, 1250, 1600, 2000, 2500, 3150, 4000, 5000, 6300, 8000, 10000, 12500, 16000, 20000];
% %             lowerBounds = centerFreqs .* 2.^(-1/6);
% %             upperBounds = centerFreqs .* 2.^(1/6);
% %         case 1/6
% %             centerFreqs = [11.2, 12.5, 14, 16, 17.8, 20, 22.4, 25, 28.2, 31.5, 35.5, 40, 45, 50, 56, 63, 71, 80, 90, 100, 112, 125, 140, 160, 178, 200, 224, 250, 282, 315, 355, 400, 450, 500, 560, 630, 710, 800, 900, 1000, 1120, 1250, 1400, 1600, 1780, 2000, 2240, 2500, 2820, 3150, 3550, 4000, 4500, 5000, 5600, 6300, 7100, 8000, 9000, 10000, 11200, 12500, 14000, 16000, 17800, 20000];
% %             lowerBounds = centerFreqs .* 2.^(-1/12);
% %             upperBounds = centerFreqs .* 2.^(1/12);
% %         case 1/12
% %             centerFreqs = [11.2, 11.9, 12.5, 13.3, 14.1, 14.9, 15.9, 16.8, 17.8, 18.8, 20, 21.1, 22.4, 23.8, 25.1, 26.6, 28.2, 29.9, 31.6, 33.5, 35.5, 37.6, 39.8, 42.2, 44.7, 47.3, 50.1, 53.1, 56.2, 59.6, 63.1, 66.8, 70.8, 75, 79.4, 84.1, 89.1, 94.4, 100, 106, 112, 119, 126, 133, 141, 149, 158, 168, 178, 188, 200, 212, 224, 238, 251, 266, 282, 299, 316, 335, 355, 376, 398, 422, 447, 473, 501, 531, 562, 596, 631, 668, 708, 750, 794, 841, 891, 944, 1000, 1060, 1120, 1190, 1260, 1330, 1410, 1490, 1580, 1680, 1780, 1880, 2000, 2120, 2240, 2380, 2510, 2660, 2820, 2990, 3160, 3350, 3550, 3760, 3980, 4220, 4470, 4730, 5010, 5310, 5620, 5960, 6310, 6680, 7080, 7500, 7940, 8410, 8910, 9440, 10000, 10600, 11200, 11900, 12600, 13300, 14100, 14900, 15800, 16800, 17800, 18800, 20000];
% %             lowerBounds = centerFreqs .* 2.^(-1/24);
% %             upperBounds = centerFreqs .* 2.^(1/24);
% %         case 1/24
% %             centerFreqs = [11.2, 11.5, 11.9, 12.2, 12.5, 12.8, 13.1, 13.4, 13.8, 14.1, 14.5, 14.8, 15.1, 15.5, 15.9, 16.2, 16.6, 16.9, 17.3, 17.7, 18.0, 18.4, 18.8, 19.1, 19.5, 20.0, 20.4, 20.8, 21.1, 21.5, 22.0, 22.4, 22.9, 23.3, 23.7, 24.1, 24.6, 25.0, 25.5, 25.9, 26.4, 26.9, 27.4, 27.9, 28.4, 28.8, 29.4, 29.9, 30.4, 30.9, 31.5, 32.0, 32.6, 33.1, 33.7, 34.2, 34.8, 35.4, 35.9, 36.5, 37.1, 37.6, 38.2, 38.8, 39.4, 40.0, 40.6, 41.2, 41.7, 42.4, 43.0, 43.6, 44.2, 44.9, 45.5, 46.1, 46.7, 47.3, 48.0, 48.6, 49.3, 50.0, 50.7, 51.3, 52.0, 52.7, 53.4, 54.1, 54.8, 55.5, 56.2, 56.9, 57.6, 58.3, 59.1, 59.9, 60.6, 61.4, 62.2, 63.0, 63.8, 64.6, 65.4, 66.2, 67.0, 67.8, 68.7, 69.5, 70.4, 71.3, 72.1, 73.0, 73.9, 74.8, 75.7, 76.6, 77.5, 78.4, 79.4, 80.3, 81.3, 82.2, 83.2, 84.1, 85.1, 86.1, 87.1, 88.1, 89.1, 90.2, 91.2, 92.3, 93.3, 94.4, 95.5, 96.6, 97.7, 98.8, 100.0, 101.1, 102.3, 103.5, 104.7, 105.9, 107.2, 108.4, 109.7, 111.0, 112.2, 113.5, 114.8, 116.1, 117.5, 118.9, 120.2, 121.6, 123.1, 124.5, 125.9, 127.4, 128.9, 130.4, 131.9, 133.4, 134.9, 136.4, 138.0, 139.5, 141.1, 142.7, 144.3, 145.9, 147.5, 149.2, 150.9, 152.5, 154.2, 155.9, 157.6, 159.4, 161.1, 162.9, 164.7, 166.5, 168.3, 170.1, 172.0, 173.9, 175.7, 177.6, 179.6, 181.5, 183.5, 185.4, 187.4, 189.4, 191.4, 193.5, 195.5, 197.6, 199.6, 201.7, 203.9, 206.0, 208.1, 210.3, 212.5, 214.7, 216.9, 219.1, 221.4, 223.7, 226.0, 228.3, 230.6, 232.9, 235.3, 237.6, 240.0, 242.4, 244.8, 247.3, 249.7, 252.2, 254.7, 257.2, 259.7, 262.3, 264.9, 267.4, 270.0, 272.6, 275.3, 277.9, 280.5, 283.2, 285.9, 288.6, 291.3, 294.0, 296.8, 299.6, 302.3, 305.1, 307.9, 310.8, 313.6, 316.5, 319.4, 322.3, 325.2, 328.1, 331.1, 334.1, 337.1, 340.1, 343.1, 346.1, 349.2, 352.3, 355.4, 358.5, 361.6, 364.7, 367.9, 371.0, 374.2, 377.4, 380.6, 383.8, 387.1, 390.3, 393.6, 396.9, 400.2, 403.5, 406.9, 410.2, 413.6, 417.0, 420.4, 423.9, 427.3, 430.8, 434.3, 437.8, 441.4, 444.9, 448.5, 452.1, 455.7, 459.3, 463.0, 466.6, 470.3, 474.0, 477.7, 481.4, 485.2, 488.9, 492.7, 496.5, 500.3, 504.1, 507.9, 511.8, 515.7, 519.6, 523.5, 527.4, 531.4, 535.4, 539.4, 543.4, 547.4, 551.5, 555.5, 559.6, 563.7, 567.9, 572.0, 576.2, 580.4, 584.6, 588.8, 593.1, 597.3, 601.6, 605.9, 610.2, 614.6, 619.0, 623.4, 627.8, 632.3, 636.7, 641.2, 645.7, 650.2, 654.8, 659.4, 664.0, 668.6, 673.3, 677.9, 682.6, 687.3, 692.0, 696.8, 701.5, 706.3, 711.1, 715.9, 720.7, 725.6, 730.5, 735.4, 740.3, 745.2, 750.2, 755.1, 760.1, 765.1, 770.1, 775.1, 780.2, 785.2, 790.3, 795.4, 800.6, 805.7, 810.9, 816.1, 821.3, 826.5, 831.8, 837.0, 842.3, 847.6, 853.0, 858.3, 863.7, 869.1, 874.6, 880.0, 885.5, 891.0, 896.6, 902.1, 907.7, 913.3, 919.0, 924.6, 930.3, 936.0, 941.7, 947.5, 953.2, 959.0, 964.8, 970.6, 976.5, 982.3, 988.2, 994.1, 1000];
% %             lowerBounds = centerFreqs .* 2.^(-1/48);
% %             upperBounds = centerFreqs .* 2.^(1/48);
% %     end
% % 
% %     % 初始化倍频程功率
% %     octaveBandPower = zeros(1, length(centerFreqs));
% % 
% %     % 计算每个频段的功率
% %     for i = 1:length(centerFreqs)
% %         fLower = lowerBounds(i);
% %         fUpper = upperBounds(i);
% %         bandIdx = (f >= fLower & f <= fUpper);
% %         octaveBandPower(i) = sum(powerSpectrum(bandIdx));
% %     end
% % 
% %     % 转换为dB单位
% %     octaveBandPower_dB = 10 * log10(octaveBandPower);
% % 
% %     % 绘制柱状图
% %     figure;
% %     x_coords = 1:length(centerFreqs);
% %     bar(x_coords, octaveBandPower_dB, 1, 'FaceColor', [0.5 0.2 0.8], 'EdgeColor', 'k');
% %     set(gca, 'XTick', x_coords);
% %     set(gca, 'XTickLabel', string(centerFreqs));
% %     xtickangle(45);
% %     xlabel('Frequency (Hz)');
% %     ylabel('Power (dB)');
% %     title([name, ' Octave Band Analysis']);
% %     xlim([0.5, length(centerFreqs) + 0.5]);
% %     grid on;
% % end
% % 
% % %% 分析和绘图
% % plotFractionalOctave(powerSpectrum, f, 1, '1');
% % plotFractionalOctave(powerSpectrum, f, 2, '2');
% % plotFractionalOctave(powerSpectrum, f, 1/3, '1/3');
% % plotFractionalOctave(powerSpectrum, f, 1/6, '1/6');
% % plotFractionalOctave(powerSpectrum, f, 1/12, '1/12');
% % plotFractionalOctave(powerSpectrum, f, 1/24, '1/24');
% % 
% % 
% % %%
% % 
% % %声品质客观评价
% % % 为了进行声品质分析，我们需要计算响度、尖锐度、粗糙度、波动度、音调度和抖动度。
% % % 这些计算通常比较复杂，需要特定的算法和模型。
% % % 以下是一个简化的示例，实际应用中可能需要更精确的模型和计算方法。
% % 
% % % 响度（Loudness）
% % % 这是一个基于功率谱的简化模型，实际应用中可能会使用更复杂的模型，如ISO 532-1或ISO 532-2
% % loudness = sum(octaveBandPower);
% % 
% % % 尖锐度（Sharpness）
% % % 尖锐度通常与频谱的重心有关，这里使用一个简化的计算方法
% % spectralCentroid = sum(f .* powerSpectrum(1:length(f))) / sum(powerSpectrum(1:length(f)));
% % sharpness = spectralCentroid / 1000; % 归一化
% % 
% % % 粗糙度（Roughness）
% % % 粗糙度与信号的快速振幅调制有关，这里使用一个简化的模型
% % % 计算信号的包络（使用希尔伯特变换）
% % envelope = abs(hilbert(soundPressureDownsampled));
% % % 计算包络的标准差作为粗糙度的估计
% % roughness = std(envelope);
% % 
% % % 波动度（Fluctuation Strength）
% % % 波动度与信号的慢速振幅调制有关，这里使用一个简化的模型
% % % 计算信号的慢速包络（例如，使用低通滤波器）
% % lowPassFilter = designfilt('lowpassfir', 'FilterOrder', 100, 'CutoffFrequency', 20, 'SampleRate', Fs);
% % slowEnvelope = filtfilt(lowPassFilter, soundPressureDownsampled);
% % % 计算慢速包络的标准差作为波动度的估计
% % fluctuation = std(slowEnvelope);
% % 
% % % 音调度（Tonality）
% % % 音调度与信号中是否存在显著的频率成分有关，这里使用一个简化的模型
% % [~, peakLocs] = findpeaks(powerSpectrum); % 找到功率谱的峰值
% % tonality = length(peakLocs) / length(powerSpectrum);
% % 
% % % 抖动度（Jitter）
% % % 抖动度通常与频率的波动有关，这里使用一个简化的模型
% % % 计算频率的标准差
% % jitter = std(f);
% % 
% % % 烦躁度（Psychoacoustic Annoyance）
% % % 烦躁度是一个综合指标，通常包括响度、尖锐度、粗糙度和音调度等
% % % 这里使用一个非常简化的模型
% % annoyance = loudness + sharpness + roughness + tonality;
% % 
% % % 显示结果
% % disp(['响度 (Loudness): ', num2str(loudness)]);
% % disp(['尖锐度 (Sharpness): ', num2str(sharpness)]);
% % disp(['粗糙度 (Roughness): ', num2str(roughness)]);
% % disp(['波动度 (Fluctuation Strength): ', num2str(fluctuation)]);
% % disp(['音调度 (Tonality): ', num2str(tonality)]);
% % disp(['抖动度 (Jitter): ', num2str(jitter)]);
% % disp(['烦躁度 (Psychoacoustic Annoyance): ', num2str(annoyance)]);
% % 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% %%
% 
% clc;
% clear;
% close all;
% 
% %% 参数设置
% excelFile = '50rpm.xlsx';
% sheetName = 1;
% timeColumn = 'Time_seconds';
% soundPressureColumn = 'Sound_pressure_PASCAL';
% 
% %% 数据读取
% data = readtable(excelFile, 'Sheet', sheetName);
% time = data.(timeColumn);
% soundPressure = data.(soundPressureColumn);
% time = time(:);
% soundPressure = soundPressure(:);
% 
% %% 绘制原始噪声信号时域图
% figure;
% plot(time, soundPressure, 'b', 'LineWidth', 1.5);
% xlabel('Time (s)');
% ylabel('Sound Pressure (Pa)');
% title('Noise Signal in Time Domain');
% grid on;
% 
% %% 下采样
% downsampleFactor = 10;
% timeDownsampled = downsample(time, downsampleFactor);
% soundPressureDownsampled = downsample(soundPressure, downsampleFactor);
% 
% % 显示下采样后的数据
% disp(['原始数据点数: ', num2str(length(time))]);
% disp(['下采样后数据点数: ', num2str(length(timeDownsampled))]);
% 
% %% 频谱分析
% Fs = 1 / mean(diff(timeDownsampled));
% L = length(soundPressureDownsampled);
% f = Fs * (0:(L/2)) / L;
% Y = fft(soundPressureDownsampled);
% P2 = abs(Y / L);
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% 
% % 绘制频谱图
% figure;
% plot(f, P1, 'r', 'LineWidth', 1.5);
% xlabel('Frequency (Hz)');
% ylabel('Amplitude');
% title('Noise Signal Spectrum (Downsampled)');
% grid on;
% 
% %% 功率谱分析
% powerSpectrum = P1.^2;
% figure;
% plot(f, 10*log10(powerSpectrum), 'g', 'LineWidth', 1.5);
% xlabel('Frequency (Hz)');
% ylabel('Power/Frequency (dB/Hz)');
% title('Power Spectrum of Noise Signal (Downsampled)');
% grid on;
% 
% %% 自相关分析
% [autocorr, lag] = xcorr(soundPressureDownsampled, 'coeff');
% lagTime = lag / Fs;
% figure;
% plot(lagTime, autocorr, 'b', 'LineWidth', 1.5);
% xlabel('Lag Time (s)');
% ylabel('Autocorrelation');
% title('Autocorrelation of Noise Signal (Downsampled)');
% grid on;
% 
% %% 倍频程分析和绘图函数
% function plotFractionalOctave(powerSpectrum, f, fraction, name)
%     % 定义中心频率和上下边界
%     switch fraction
%         case 1
%             centerFreqs = [31.5, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000];
%             lowerBounds = centerFreqs ./ sqrt(2);
%             upperBounds = centerFreqs .* sqrt(2);
%         case 2
%             centerFreqs = [31.5, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000];
%             lowerBounds = centerFreqs ./ 2;
%             upperBounds = centerFreqs .* 2;
%         case 1/3
%             centerFreqs = [12.5, 16, 20, 25, 31.5, 40, 50, 63, 80, 100, 125, 160, 200, 250, 315, 400, 500, 630, 800, 1000, 1250, 1600, 2000, 2500, 3150, 4000, 5000, 6300, 8000, 10000, 12500, 16000, 20000];
%             lowerBounds = centerFreqs .* 2.^(-1/6);
%             upperBounds = centerFreqs .* 2.^(1/6);
%         case 1/6
%             centerFreqs = [11.2, 12.5, 14, 16, 17.8, 20, 22.4, 25, 28.2, 31.5, 35.5, 40, 45, 50, 56, 63, 71, 80, 90, 100, 112, 125, 140, 160, 178, 200, 224, 250, 282, 315, 355, 400, 450, 500, 560, 630, 710, 800, 900, 1000, 1120, 1250, 1400, 1600, 1780, 2000, 2240, 2500, 2820, 3150, 3550, 4000, 4500, 5000, 5600, 6300, 7100, 8000, 9000, 10000, 11200, 12500, 14000, 16000, 17800, 20000];
%             lowerBounds = centerFreqs .* 2.^(-1/12);
%             upperBounds = centerFreqs .* 2.^(1/12);
%         case 1/12
%             centerFreqs = [11.2, 11.9, 12.5, 13.3, 14.1, 14.9, 15.9, 16.8, 17.8, 18.8, 20, 21.1, 22.4, 23.8, 25.1, 26.6, 28.2, 29.9, 31.6, 33.5, 35.5, 37.6, 39.8, 42.2, 44.7, 47.3, 50.1, 53.1, 56.2, 59.6, 63.1, 66.8, 70.8, 75, 79.4, 84.1, 89.1, 94.4, 100, 106, 112, 119, 126, 133, 141, 149, 158, 168, 178, 188, 200, 212, 224, 238, 251, 266, 282, 299, 316, 335, 355, 376, 398, 422, 447, 473, 501, 531, 562, 596, 631, 668, 708, 750, 794, 841, 891, 944, 1000, 1060, 1120, 1190, 1260, 1330, 1410, 1490, 1580, 1680, 1780, 1880, 2000, 2120, 2240, 2380, 2510, 2660, 2820, 2990, 3160, 3350, 3550, 3760, 3980, 4220, 4470, 4730, 5010, 5310, 5620, 5960, 6310, 6680, 7080, 7500, 7940, 8410, 8910, 9440, 10000, 10600, 11200, 11900, 12600, 13300, 14100, 14900, 15800, 16800, 17800, 18800, 20000];
%             lowerBounds = centerFreqs .* 2.^(-1/24);
%             upperBounds = centerFreqs .* 2.^(1/24);
%         case 1/24
%             centerFreqs = [11.2, 11.5, 11.9, 12.2, 12.5, 12.8, 13.1, 13.4, 13.8, 14.1, 14.5, 14.8, 15.1, 15.5, 15.9, 16.2, 16.6, 16.9, 17.3, 17.7, 18.0, 18.4, 18.8, 19.1, 19.5, 20.0, 20.4, 20.8, 21.1, 21.5, 22.0, 22.4, 22.9, 23.3, 23.7, 24.1, 24.6, 25.0, 25.5, 25.9, 26.4, 26.9, 27.4, 27.9, 28.4, 28.8, 29.4, 29.9, 30.4, 30.9, 31.5, 32.0, 32.6, 33.1, 33.7, 34.2, 34.8, 35.4, 35.9, 36.5, 37.1, 37.6, 38.2, 38.8, 39.4, 40.0, 40.6, 41.2, 41.7, 42.4, 43.0, 43.6, 44.2, 44.9, 45.5, 46.1, 46.7, 47.3, 48.0, 48.6, 49.3, 50.0, 50.7, 51.3, 52.0, 52.7, 53.4, 54.1, 54.8, 55.5, 56.2, 56.9, 57.6, 58.3, 59.1, 59.9, 60.6, 61.4, 62.2, 63.0, 63.8, 64.6, 65.4, 66.2, 67.0, 67.8, 68.7, 69.5, 70.4, 71.3, 72.1, 73.0, 73.9, 74.8, 75.7, 76.6, 77.5, 78.4, 79.4, 80.3, 81.3, 82.2, 83.2, 84.1, 85.1, 86.1, 87.1, 88.1, 89.1, 90.2, 91.2, 92.3, 93.3, 94.4, 95.5, 96.6, 97.7, 98.8, 100.0, 101.1, 102.3, 103.5, 104.7, 105.9, 107.2, 108.4, 109.7, 111.0, 112.2, 113.5, 114.8, 116.1, 117.5, 118.9, 120.2, 121.6, 123.1, 124.5, 125.9, 127.4, 128.9, 130.4, 131.9, 133.4, 134.9, 136.4, 138.0, 139.5, 141.1, 142.7, 144.3, 145.9, 147.5, 149.2, 150.9, 152.5, 154.2, 155.9, 157.6, 159.4, 161.1, 162.9, 164.7, 166.5, 168.3, 170.1, 172.0, 173.9, 175.7, 177.6, 179.6, 181.5, 183.5, 185.4, 187.4, 189.4, 191.4, 193.5, 195.5, 197.6, 199.6, 201.7, 203.9, 206.0, 208.1, 210.3, 212.5, 214.7, 216.9, 219.1, 221.4, 223.7, 226.0, 228.3, 230.6, 232.9, 235.3, 237.6, 240.0, 242.4, 244.8, 247.3, 249.7, 252.2, 254.7, 257.2, 259.7, 262.3, 264.9, 267.4, 270.0, 272.6, 275.3, 277.9, 280.5, 283.2, 285.9, 288.6, 291.3, 294.0, 296.8, 299.6, 302.3, 305.1, 307.9, 310.8, 313.6, 316.5, 319.4, 322.3, 325.2, 328.1, 331.1, 334.1, 337.1, 340.1, 343.1, 346.1, 349.2, 352.3, 355.4, 358.5, 361.6, 364.7, 367.9, 371.0, 374.2, 377.4, 380.6, 383.8, 387.1, 390.3, 393.6, 396.9, 400.2, 403.5, 406.9, 410.2, 413.6, 417.0, 420.4, 423.9, 427.3, 430.8, 434.3, 437.8, 441.4, 444.9, 448.5, 452.1, 455.7, 459.3, 463.0, 466.6, 470.3, 474.0, 477.7, 481.4, 485.2, 488.9, 492.7, 496.5, 500.3, 504.1, 507.9, 511.8, 515.7, 519.6, 523.5, 527.4, 531.4, 535.4, 539.4, 543.4, 547.4, 551.5, 555.5, 559.6, 563.7, 567.9, 572.0, 576.2, 580.4, 584.6, 588.8, 593.1, 597.3, 601.6, 605.9, 610.2, 614.6, 619.0, 623.4, 627.8, 632.3, 636.7, 641.2, 645.7, 650.2, 654.8, 659.4, 664.0, 668.6, 673.3, 677.9, 682.6, 687.3, 692.0, 696.8, 701.5, 706.3, 711.1, 715.9, 720.7, 725.6, 730.5, 735.4, 740.3, 745.2, 750.2, 755.1, 760.1, 765.1, 770.1, 775.1, 780.2, 785.2, 790.3, 795.4, 800.6, 805.7, 810.9, 816.1, 821.3, 826.5, 831.8, 837.0, 842.3, 847.6, 853.0, 858.3, 863.7, 869.1, 874.6, 880.0, 885.5, 891.0, 896.6, 902.1, 907.7, 913.3, 919.0, 924.6, 930.3, 936.0, 941.7, 947.5, 953.2, 959.0, 964.8, 970.6, 976.5, 982.3, 988.2, 994.1, 1000];
%             lowerBounds = centerFreqs .* 2.^(-1/48);
%             upperBounds = centerFreqs .* 2.^(1/48);
%     end
% 
%     % 初始化倍频程功率
%     octaveBandPower = zeros(1, length(centerFreqs));
% 
%     % 计算每个频段的功率
%     for i = 1:length(centerFreqs)
%         fLower = lowerBounds(i);
%         fUpper = upperBounds(i);
%         bandIdx = (f >= fLower & f <= fUpper);
%         octaveBandPower(i) = sum(powerSpectrum(bandIdx));
%     end
% 
%     % 转换为dB单位
%     octaveBandPower_dB = 10 * log10(octaveBandPower);
% 
%     % 绘制柱状图
%     figure;
%     x_coords = 1:length(centerFreqs);
%     bar(x_coords, octaveBandPower_dB, 1, 'FaceColor', [0.5 0.2 0.8], 'EdgeColor', 'k');
%     set(gca, 'XTick', x_coords);
%     set(gca, 'XTickLabel', string(centerFreqs));
%     xtickangle(45);
%     xlabel('Frequency (Hz)');
%     ylabel('Power (dB)');
%     title([name, ' Octave Band Analysis']);
%     xlim([0.5, length(centerFreqs) + 0.5]);
%     grid on;
% end
% 
% %% 分析和绘图
% plotFractionalOctave(powerSpectrum, f, 1, '1');
% plotFractionalOctave(powerSpectrum, f, 2, '2');
% plotFractionalOctave(powerSpectrum, f, 1/3, '1/3');
% plotFractionalOctave(powerSpectrum, f, 1/6, '1/6');
% plotFractionalOctave(powerSpectrum, f, 1/12, '1/12');
% plotFractionalOctave(powerSpectrum, f, 1/24, '1/24');
% 
% %% 声品质分析
% % 确保安装了 Audio Toolbox
% if ~license('test', 'Audio_Toolbox')
%     error('需要安装 Audio Toolbox 才能进行声品质分析。');
% end
% 
% % 使用原始采样率进行声品质分析，因为这些指标通常对采样率敏感
% Fs_original = 1 / mean(diff(time));
% 
% % 响度 (Loudness)
% [loudness_values, time_loudness] = loudness(soundPressure, Fs_original);
% integratedLoudness = mean(loudness_values); % 可以计算平均响度
% 
% % 尖锐度数 (Sharpness)
% sharpness_value = sharpness(soundPressure, Fs_original);
% 
% % 粗糙度 (Roughness)
% roughness_value = roughness(soundPressure, Fs_original);
% 
% % 波动度 (Fluctuation Strength)
% fluctuationStrength_value = fluctuationStrength(soundPressure, Fs_original);
% 
% % 音调度 (Tonality)
% tonality_value = tonality(soundPressure, Fs_original);
% 
% % 抖动度 (Jerk) -  这里使用时域信号的导数来近似，实际抖动度通常用于描述机械振动
% % 可以考虑使用加速度信号计算更精确的抖动度，但这里只有声压信号
% % 假设声压与加速度有一定的相关性，可以使用其导数的幅度来近似
% jerk_signal = diff(diff(soundPressure)) * Fs_original^2; % 二阶导数
% jerk_value = rms(jerk_signal); % 使用均方根作为抖动度的衡量
% 
% % 烦躁度 (Annoyance) - 烦躁度是一个更主观的指标，没有直接的函数计算
% % 通常需要结合其他声品质指标进行评估。这里简单地提示一下。
% % annoyance_estimate = ... %  需要根据具体模型或方法进行计算
% 
% %% 输出声品质分析结果
% disp(' ');
% disp('声品质分析结果:');
% disp(['  响度 (Sones): ', num2str(integratedLoudness)]);
% disp(['  尖锐度数 (Acum): ', num2str(sharpness_value)]);
% disp(['  粗糙度 (Asper): ', num2str(roughness_value)]);
% disp(['  波动度 (Vacil): ', num2str(fluctuationStrength_value)]);
% disp(['  音调度: ', num2str(tonality_value)]);
% disp(['  抖动度 (近似值): ', num2str(jerk_value)]);
% disp('  烦躁度:  通常需要结合响度、尖锐度、粗糙度等指标进行主观或模型评估。');
% 
% %% (可选) 绘制响度随时间变化的图
% figure;
% plot(time(1:length(time_loudness)), loudness_values, 'm', 'LineWidth', 1.5);
% xlabel('Time (s)');
% ylabel('Loudness (Sones)');
% title('Loudness of Noise Signal over Time');
% grid on;



%%
clc;
clear;
close all;

%% 参数设置
excelFile = '50rpm.xlsx';
sheetName = 1;
timeColumn = 'Time_seconds';
soundPressureColumn = 'Sound_pressure_PASCAL';


%% 数据读取
data = readtable(excelFile, 'Sheet', sheetName);
time = data.(timeColumn);
soundPressure = data.(soundPressureColumn);
time = time(:);
soundPressure = soundPressure(:);

%% 绘制原始噪声信号时域图
figure;
plot(time, soundPressure, 'b', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Sound Pressure (Pa)');
title('Noise Signal in Time Domain');
grid on;

%% 下采样
downsampleFactor = 10;
timeDownsampled = downsample(time, downsampleFactor);
soundPressureDownsampled = downsample(soundPressure, downsampleFactor);

% 显示下采样后的数据
disp(['原始数据点数: ', num2str(length(time))]);
disp(['下采样后数据点数: ', num2str(length(timeDownsampled))]);

%% 频谱分析
Fs = 1 / mean(diff(timeDownsampled));
L = length(soundPressureDownsampled);
f = Fs * (0:(L/2)) / L;
Y = fft(soundPressureDownsampled);
P2 = abs(Y / L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

% 绘制频谱图
figure;
plot(f, P1, 'r', 'LineWidth', 1.5);
xlabel('Frequency (Hz)');
ylabel('Amplitude');
title('Noise Signal Spectrum (Downsampled)');
grid on;

%% 功率谱分析
powerSpectrum = P1.^2;
figure;
plot(f, 10*log10(powerSpectrum), 'g', 'LineWidth', 1.5);
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
title('Power Spectrum of Noise Signal (Downsampled)');
grid on;

%% 自相关分析
[autocorr, lag] = xcorr(soundPressureDownsampled, 'coeff');
lagTime = lag / Fs;
figure;
plot(lagTime, autocorr, 'b', 'LineWidth', 1.5);
xlabel('Lag Time (s)');
ylabel('Autocorrelation');
title('Autocorrelation of Noise Signal (Downsampled)');
grid on;

%% 倍频程分析和绘图函数
function plotFractionalOctave(powerSpectrum, f, fraction, name)
    % 定义中心频率和上下边界
    switch fraction
        case 1
            centerFreqs = [31.5, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000];
            lowerBounds = centerFreqs ./ sqrt(2);
            upperBounds = centerFreqs .* sqrt(2);
        case 2
            centerFreqs = [31.5, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000];
            lowerBounds = centerFreqs ./ 2;
            upperBounds = centerFreqs .* 2;
        case 1/3
            centerFreqs = [12.5, 16, 20, 25, 31.5, 40, 50, 63, 80, 100, 125, 160, 200, 250, 315, 400, 500, 630, 800, 1000, 1250, 1600, 2000, 2500, 3150, 4000, 5000, 6300, 8000, 10000, 12500, 16000, 20000];
            lowerBounds = centerFreqs .* 2.^(-1/6);
            upperBounds = centerFreqs .* 2.^(1/6);
        case 1/6
            centerFreqs = [11.2, 12.5, 14, 16, 17.8, 20, 22.4, 25, 28.2, 31.5, 35.5, 40, 45, 50, 56, 63, 71, 80, 90, 100, 112, 125, 140, 160, 178, 200, 224, 250, 282, 315, 355, 400, 450, 500, 560, 630, 710, 800, 900, 1000, 1120, 1250, 1400, 1600, 1780, 2000, 2240, 2500, 2820, 3150, 3550, 4000, 4500, 5000, 5600, 6300, 7100, 8000, 9000, 10000, 11200, 12500, 14000, 16000, 17800, 20000];
            lowerBounds = centerFreqs .* 2.^(-1/12);
            upperBounds = centerFreqs .* 2.^(1/12);
        case 1/12
            centerFreqs = [11.2, 11.9, 12.5, 13.3, 14.1, 14.9, 15.9, 16.8, 17.8, 18.8, 20, 21.1, 22.4, 23.8, 25.1, 26.6, 28.2, 29.9, 31.6, 33.5, 35.5, 37.6, 39.8, 42.2, 44.7, 47.3, 50.1, 53.1, 56.2, 59.6, 63.1, 66.8, 70.8, 75, 79.4, 84.1, 89.1, 94.4, 100, 106, 112, 119, 126, 133, 141, 149, 158, 168, 178, 188, 200, 212, 224, 238, 251, 266, 282, 299, 316, 335, 355, 376, 398, 422, 447, 473, 501, 531, 562, 596, 631, 668, 708, 750, 794, 841, 891, 944, 1000, 1060, 1120, 1190, 1260, 1330, 1410, 1490, 1580, 1680, 1780, 1880, 2000, 2120, 2240, 2380, 2510, 2660, 2820, 2990, 3160, 3350, 3550, 3760, 3980, 4220, 4470, 4730, 5010, 5310, 5620, 5960, 6310, 6680, 7080, 7500, 7940, 8410, 8910, 9440, 10000, 10600, 11200, 11900, 12600, 13300, 14100, 14900, 15800, 16800, 17800, 18800, 20000];
            lowerBounds = centerFreqs .* 2.^(-1/24);
            upperBounds = centerFreqs .* 2.^(1/24);
        case 1/24
            centerFreqs = [11.2, 11.5, 11.9, 12.2, 12.5, 12.8, 13.1, 13.4, 13.8, 14.1, 14.5, 14.8, 15.1, 15.5, 15.9, 16.2, 16.6, 16.9, 17.3, 17.7, 18.0, 18.4, 18.8, 19.1, 19.5, 20.0, 20.4, 20.8, 21.1, 21.5, 22.0, 22.4, 22.9, 23.3, 23.7, 24.1, 24.6, 25.0, 25.5, 25.9, 26.4, 26.9, 27.4, 27.9, 28.4, 28.8, 29.4, 29.9, 30.4, 30.9, 31.5, 32.0, 32.6, 33.1, 33.7, 34.2, 34.8, 35.4, 35.9, 36.5, 37.1, 37.6, 38.2, 38.8, 39.4, 40.0, 40.6, 41.2, 41.7, 42.4, 43.0, 43.6, 44.2, 44.9, 45.5, 46.1, 46.7, 47.3, 48.0, 48.6, 49.3, 50.0, 50.7, 51.3, 52.0, 52.7, 53.4, 54.1, 54.8, 55.5, 56.2, 56.9, 57.6, 58.3, 59.1, 59.9, 60.6, 61.4, 62.2, 63.0, 63.8, 64.6, 65.4, 66.2, 67.0, 67.8, 68.7, 69.5, 70.4, 71.3, 72.1, 73.0, 73.9, 74.8, 75.7, 76.6, 77.5, 78.4, 79.4, 80.3, 81.3, 82.2, 83.2, 84.1, 85.1, 86.1, 87.1, 88.1, 89.1, 90.2, 91.2, 92.3, 93.3, 94.4, 95.5, 96.6, 97.7, 98.8, 100.0, 101.1, 102.3, 103.5, 104.7, 105.9, 107.2, 108.4, 109.7, 111.0, 112.2, 113.5, 114.8, 116.1, 117.5, 118.9, 120.2, 121.6, 123.1, 124.5, 125.9, 127.4, 128.9, 130.4, 131.9, 133.4, 134.9, 136.4, 138.0, 139.5, 141.1, 142.7, 144.3, 145.9, 147.5, 149.2, 150.9, 152.5, 154.2, 155.9, 157.6, 159.4, 161.1, 162.9, 164.7, 166.5, 168.3, 170.1, 172.0, 173.9, 175.7, 177.6, 179.6, 181.5, 183.5, 185.4, 187.4, 189.4, 191.4, 193.5, 195.5, 197.6, 199.6, 201.7, 203.9, 206.0, 208.1, 210.3, 212.5, 214.7, 216.9, 219.1, 221.4, 223.7, 226.0, 228.3, 230.6, 232.9, 235.3, 237.6, 240.0, 242.4, 244.8, 247.3, 249.7, 252.2, 254.7, 257.2, 259.7, 262.3, 264.9, 267.4, 270.0, 272.6, 275.3, 277.9, 280.5, 283.2, 285.9, 288.6, 291.3, 294.0, 296.8, 299.6, 302.3, 305.1, 307.9, 310.8, 313.6, 316.5, 319.4, 322.3, 325.2, 328.1, 331.1, 334.1, 337.1, 340.1, 343.1, 346.1, 349.2, 352.3, 355.4, 358.5, 361.6, 364.7, 367.9, 371.0, 374.2, 377.4, 380.6, 383.8, 387.1, 390.3, 393.6, 396.9, 400.2, 403.5, 406.9, 410.2, 413.6, 417.0, 420.4, 423.9, 427.3, 430.8, 434.3, 437.8, 441.4, 444.9, 448.5, 452.1, 455.7, 459.3, 463.0, 466.6, 470.3, 474.0, 477.7, 481.4, 485.2, 488.9, 492.7, 496.5, 500.3, 504.1, 507.9, 511.8, 515.7, 519.6, 523.5, 527.4, 531.4, 535.4, 539.4, 543.4, 547.4, 551.5, 555.5, 559.6, 563.7, 567.9, 572.0, 576.2, 580.4, 584.6, 588.8, 593.1, 597.3, 601.6, 605.9, 610.2, 614.6, 619.0, 623.4, 627.8, 632.3, 636.7, 641.2, 645.7, 650.2, 654.8, 659.4, 664.0, 668.6, 673.3, 677.9, 682.6, 687.3, 692.0, 696.8, 701.5, 706.3, 711.1, 715.9, 720.7, 725.6, 730.5, 735.4, 740.3, 745.2, 750.2, 755.1, 760.1, 765.1, 770.1, 775.1, 780.2, 785.2, 790.3, 795.4, 800.6, 805.7, 810.9, 816.1, 821.3, 826.5, 831.8, 837.0, 842.3, 847.6, 853.0, 858.3, 863.7, 869.1, 874.6, 880.0, 885.5, 891.0, 896.6, 902.1, 907.7, 913.3, 919.0, 924.6, 930.3, 936.0, 941.7, 947.5, 953.2, 959.0, 964.8, 970.6, 976.5, 982.3, 988.2, 994.1, 1000];
            lowerBounds = centerFreqs .* 2.^(-1/48);
            upperBounds = centerFreqs .* 2.^(1/48);
    end

    % 初始化倍频程功率
    octaveBandPower = zeros(1, length(centerFreqs));

    % 计算每个频段的功率
    for i = 1:length(centerFreqs)
        fLower = lowerBounds(i);
        fUpper = upperBounds(i);
        bandIdx = (f >= fLower & f <= fUpper);
        octaveBandPower(i) = sum(powerSpectrum(bandIdx));
    end

    % 转换为dB单位
    octaveBandPower_dB = 10 * log10(octaveBandPower);

    % 绘制柱状图
    figure;
    x_coords = 1:length(centerFreqs);
    bar(x_coords, octaveBandPower_dB, 1, 'FaceColor', [0.5 0.2 0.8], 'EdgeColor', 'k');
    set(gca, 'XTick', x_coords);
    set(gca, 'XTickLabel', string(centerFreqs));
    xtickangle(45);
    xlabel('Frequency (Hz)');
    ylabel('Power (dB)');
    title([name, ' Octave Band Analysis']);
    xlim([0.5, length(centerFreqs) + 0.5]);
    grid on;
end

%% 分析和绘图
plotFractionalOctave(powerSpectrum, f, 1, '1');
plotFractionalOctave(powerSpectrum, f, 2, '2');
plotFractionalOctave(powerSpectrum, f, 1/3, '1/3');
plotFractionalOctave(powerSpectrum, f, 1/6, '1/6');
plotFractionalOctave(powerSpectrum, f, 1/12, '1/12');
plotFractionalOctave(powerSpectrum, f, 1/24, '1/24');


