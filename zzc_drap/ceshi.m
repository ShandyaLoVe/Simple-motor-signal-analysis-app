function signal_processing()
    % 创建 GUI 界面
    fig = uifigure('Name', '信号读取与处理', 'Position', [100 100 600 600]);
    
    % 文件选择按钮
    btnLoad = uibutton(fig, 'push', 'Text', '选择文件', 'Position', [50 500 100 30]);
    lblFile = uilabel(fig, 'Text', '未选择文件', 'Position', [170 500 350 30], 'HorizontalAlignment', 'left');
    btnLoad.ButtonPushedFcn = @(~,~) loadFile(lblFile);
    
    % 输入截取区间
    uilabel(fig, 'Text', '起始时间(s):', 'Position', [50 450 100 30]);
    startTime = uieditfield(fig, 'numeric', 'Position', [150 450 100 30]);
    uilabel(fig, 'Text', '结束时间(s):', 'Position', [280 450 100 30]);
    endTime = uieditfield(fig, 'numeric', 'Position', [380 450 100 30]);
    
    % 截取和保存按钮
    btnSave = uibutton(fig, 'push', 'Text', '截取并保存', 'Position', [50 400 100 30]);
    lblSave = uilabel(fig, 'Text', '', 'Position', [170 400 350 30], 'HorizontalAlignment', 'left');
    btnSave.ButtonPushedFcn = @(~,~) processAndSave(lblFile, startTime, endTime, lblSave, fig);
    
    % 重采样模块
    uilabel(fig, 'Text', '重采样倍率:', 'Position', [50 350 100 30]);
    resampleFactor = uieditfield(fig, 'numeric', 'Position', [150 350 100 30]);
    btnResample = uibutton(fig, 'push', 'Text', '重采样', 'Position', [50 300 100 30]);
    btnResample.ButtonPushedFcn = @(~,~) resampleSignal(lblFile, resampleFactor, fig);
    
    % 时域特征值计算
    btnStats = uibutton(fig, 'push', 'Text', '计算时域特征', 'Position', [50 250 100 30]);
    lblStats = uilabel(fig, 'Text', '', 'Position', [170 250 350 60], 'HorizontalAlignment', 'left');
    btnStats.ButtonPushedFcn = @(~,~) computeStats(lblFile, lblStats, fig);
    
    % 去均值按钮
    btnDemean = uibutton(fig, 'push', 'Text', '去均值', 'Position', [50 200 100 30]);
    btnDemean.ButtonPushedFcn = @(~,~) demeanSignal(lblFile, fig);
    
    % 预滤波按钮
    btnFilter = uibutton(fig, 'push', 'Text', '预滤波', 'Position', [50 150 100 30]);
    btnFilter.ButtonPushedFcn = @(~,~) filterSignal(lblFile, fig);
    
    % 频谱分析按钮
    btnSpectrum = uibutton(fig, 'push', 'Text', '频谱分析', 'Position', [50 100 100 30]);
    btnSpectrum.ButtonPushedFcn = @(~,~) spectrumAnalysis(lblFile, fig);
    
    % 功率谱分析按钮
    btnPowerSpectrum = uibutton(fig, 'push', 'Text', '功率谱分析', 'Position', [200 100 100 30]);
    btnPowerSpectrum.ButtonPushedFcn = @(~,~) powerSpectrumAnalysis(lblFile, fig);
    
    % 自相关按钮
    btnAutoCorr = uibutton(fig, 'push', 'Text', '自相关分析', 'Position', [350 100 100 30]);
    btnAutoCorr.ButtonPushedFcn = @(~,~) autoCorrelationAnalysis(lblFile, fig);
    
    % 互相关按钮
    btnCrossCorr = uibutton(fig, 'push', 'Text', '互相关分析', 'Position', [500 100 100 30]);
    btnCrossCorr.ButtonPushedFcn = @(~,~) crossCorrelationAnalysis(lblFile, fig);
end

function loadFile(lblFile)
    % 打开文件选择对话框
    [fileName, filePath] = uigetfile({'*.xlsx;*.csv;*.txt', 'Supported Files (*.xlsx, *.csv, *.txt)'}, '选择文件');
    if fileName == 0
        return; % 用户取消操作
    end
    lblFile.Text = fullfile(filePath, fileName);
end

function processAndSave(lblFile, startTimeField, endTimeField, lblSave, fig)
    % 检查文件是否已选择
    if strcmp(lblFile.Text, '未选择文件')
        uialert(fig, '请先选择文件', '错误');
        return;
    end
    
    % 获取截取时间区间
    startTime = startTimeField.Value;
    endTime = endTimeField.Value;
    if isempty(startTime) || isempty(endTime) || startTime >= endTime
        uialert(fig, '请正确输入起始和结束时间', '错误');
        return;
    end
    
    % 读取文件
    filePath = lblFile.Text;
    data = readFile(filePath);
    
    % 截取信号
    time = data.Time_seconds;
    idx = (time >= startTime) & (time <= endTime);
    if ~any(idx)
        uialert(fig, '指定时间范围内没有数据', '错误');
        return;
    end
    croppedData = data(idx, :);
    
    % 保存截取后的数据
    [saveFile, savePath] = uiputfile({'*.xlsx', 'Excel Files (*.xlsx)'; '*.csv', 'CSV Files (*.csv)'; '*.txt', 'Text Files (*.txt)'}, '保存文件为');
    if saveFile == 0
        return; % 用户取消保存操作
    end
    saveFullPath = fullfile(savePath, saveFile);
    writeFile(croppedData, saveFullPath);
    uialert(fig, ['文件已保存至: ', saveFullPath], '成功');
end

function resampleSignal(lblFile, resampleFactorField, fig)
    % 检查文件是否已选择
    if strcmp(lblFile.Text, '未选择文件')
        uialert(fig, '请先选择文件', '错误');
        return;
    end
    
    % 获取重采样倍率
    resampleFactor = resampleFactorField.Value;
    if isempty(resampleFactor) || resampleFactor <= 0
        uialert(fig, '请输入一个正的重采样倍率', '错误');
        return;
    end
    
    % 读取文件
    filePath = lblFile.Text;
    data = readFile(filePath);
    
    % 获取原始信号和时间
    time = data.Time_seconds;
    soundPressure = data.Sound_pressure_PASCAL;
    acceleration = data.Acceleration_in_meters_per_second;
    
    % 计算原始采样率
    originalFs = 1 / mean(diff(time));
    newFs = originalFs * resampleFactor;
    
    % 重采样
    [soundPressureResampled, timeResampled] = resample(soundPressure, time, newFs);
    [accelerationResampled, ~] = resample(acceleration, time, newFs);
    
    % 创建新的表，并保存结果
    resampledData = table(timeResampled, soundPressureResampled, accelerationResampled, ...
        'VariableNames', {'Time_seconds', 'Sound_pressure_PASCAL', 'Acceleration_in_meters_per_second'});    
    [saveFile, savePath] = uiputfile({'*.xlsx', 'Excel Files (*.xlsx)'; '*.csv', 'CSV Files (*.csv)'; '*.txt', 'Text Files (*.txt)'}, '保存重采样信号为');
    if saveFile == 0
        return; % 用户取消保存操作
    end
    saveFullPath = fullfile(savePath, saveFile);
    writeFile(resampledData, saveFullPath);
    uialert(fig, ['文件已保存至: ', saveFullPath], '成功');
end

function computeStats(lblFile, lblStats, fig)
    % 检查文件是否已选择
    if strcmp(lblFile.Text, '未选择文件')
        uialert(fig, '请先选择文件', '错误');
        return;
    end
    
    % 读取文件
    filePath = lblFile.Text;
    data = readFile(filePath);
    
    % 获取信号
    signal = data.Sound_pressure_PASCAL; % 这里以 Sound_pressure_PASCAL 为示例信号
    
    % 计算时域特征
    maxVal = max(signal);
    minVal = min(signal);
    peakToPeak = maxVal - minVal;
    meanVal = mean(signal);
    % 显示结果
    statsText = sprintf('最大值: %.3f\n最小值: %.3f\n峰峰值: %.3f\n均值: %.3f', maxVal, minVal, peakToPeak, meanVal);
    lblStats.Text = statsText;
end

function demeanSignal(lblFile, fig)
    % 检查文件是否已选择
    if strcmp(lblFile.Text, '未选择文件')
        uialert(fig, '请先选择文件', '错误');
        return;
    end
    
    % 读取文件
    filePath = lblFile.Text;
    data = readFile(filePath);
    
    % 去均值
    signal = data.Sound_pressure_PASCAL;
    demeanedSignal = signal - mean(signal);
    data.Sound_pressure_PASCAL = demeanedSignal;
    
    % 保存去均值后的数据
    [saveFile, savePath] = uiputfile({'*.xlsx', 'Excel Files (*.xlsx)'; '*.csv', 'CSV Files (*.csv)'; '*.txt', 'Text Files (*.txt)'}, '保存去均值信号为');
    if saveFile == 0
        return;
    end
    saveFullPath = fullfile(savePath, saveFile);
    writeFile(data, saveFullPath);
    uialert(fig, ['文件已保存至: ', saveFullPath], '成功');
end

function filterSignal(lblFile, fig)
    % 检查文件是否已选择
    if strcmp(lblFile.Text, '未选择文件')
        uialert(fig, '请先选择文件', '错误');
        return;
    end
    
    % 读取文件
    filePath = lblFile.Text;
    data = readFile(filePath);
    
    % 获取信号
    signal = data.Sound_pressure_PASCAL;
    
    % 设计滤波器（低通滤波器，截止频率 50 Hz）
    fs = 1 / mean(diff(data.Time_seconds)); % 采样率
    cutoffFreq = 50; % 截止频率
    [b, a] = butter(4, cutoffFreq / (fs / 2)); % 4 阶 Butterworth 滤波器
    filteredSignal = filtfilt(b, a, signal);
    data.Sound_pressure_PASCAL = filteredSignal;
    
    % 保存滤波后的数据
    [saveFile, savePath] = uiputfile({'*.xlsx', 'Excel Files (*.xlsx)'; '*.csv', 'CSV Files (*.csv)'; '*.txt', 'Text Files (*.txt)'}, '保存滤波信号为');
    if saveFile == 0
        return;
    end
    saveFullPath = fullfile(savePath, saveFile);
    writeFile(data, saveFullPath);
    uialert(fig, ['文件已保存至: ', saveFullPath], '成功');
end

% 频谱分析
function spectrumAnalysis(lblFile, fig)
    % 检查文件是否已选择
    if strcmp(lblFile.Text, '未选择文件')
        uialert(fig, '请先选择文件', '错误');
        return;
    end
    
    % 读取文件
    filePath = lblFile.Text;
    data = readFile(filePath);
    
    % 获取信号
    signal = data.Sound_pressure_PASCAL; % 或者选择适当的信号字段
    
    % 计算信号的傅里叶变换并绘制频谱
    fs = 1 / mean(diff(data.Time_seconds)); % 采样率
    n = length(signal);
    f = (0:n-1)*(fs/n); % 频率轴
    Y = fft(signal); % 傅里叶变换
    Y = abs(Y(1:n/2)); % 取前半部分
    
    % 绘制频谱图
    figure;
    plot(f(1:n/2), Y);
    title('信号频谱');
    xlabel('频率 (Hz)');
    ylabel('幅值');
end

% 功率谱分析
function powerSpectrumAnalysis(lblFile, fig)
    % 检查文件是否已选择
    if strcmp(lblFile.Text, '未选择文件')
        uialert(fig, '请先选择文件', '错误');
        return;
    end
    
    % 读取文件
    filePath = lblFile.Text;
    data = readFile(filePath);
    
    % 获取信号
    signal = data.Sound_pressure_PASCAL; % 或者选择适当的信号字段
    
    % 计算功率谱
    fs = 1 / mean(diff(data.Time_seconds)); % 采样率
    n = length(signal);
    [Pxx, Freq] = pwelch(signal, [], [], [], fs);
    
    % 绘制功率谱图
    figure;
    plot(Freq, 10*log10(Pxx)); % 以 dB 绘制功率谱
    title('功率谱');
    xlabel('频率 (Hz)');
    ylabel('功率 (dB)');
end

% 自相关分析
function autoCorrelationAnalysis(lblFile, fig)
    % 检查文件是否已选择
    if strcmp(lblFile.Text, '未选择文件')
        uialert(fig, '请先选择文件', '错误');
        return;
    end
    
    % 读取文件
    filePath = lblFile.Text;
    data = readFile(filePath);
    
    % 获取信号
    signal = data.Sound_pressure_PASCAL; % 或者选择适当的信号字段
    
    % 计算并绘制自相关
    [acor, lag] = xcorr(signal, 'coeff'); % 归一化自相关
    figure;
    plot(lag, acor);
    title('自相关分析');
    xlabel('滞后');
    ylabel('自相关系数');
end

% 互相关分析
function crossCorrelationAnalysis(lblFile, fig)
    % 检查文件是否已选择
    if strcmp(lblFile.Text, '未选择文件')
        uialert(fig, '请先选择文件', '错误');
        return;
    end
    
    % 读取文件
    filePath = lblFile.Text;
    data = readFile(filePath);
    
    % 获取信号
    signal1 = data.Sound_pressure_PASCAL; % 或者选择适当的信号字段
    signal2 = data.Acceleration_in_meters_per_second; % 第二个信号
    
    % 计算并绘制互相关
    [xcorr_val, lag] = xcorr(signal1, signal2, 'coeff'); % 归一化互相关
    figure;
    plot(lag, xcorr_val);
    title('互相关分析');
    xlabel('滞后');
    ylabel('互相关系数');
end

% 文件读取函数
function data = readFile(filePath)
    [~, ~, ext] = fileparts(filePath);
    switch lower(ext)
        case '.xlsx'
            data = readtable(filePath);
        case '.csv'
            data = readtable(filePath);
        case '.txt'
            data = readtable(filePath, 'Delimiter', '\t');
        otherwise
            error('不支持的文件格式');
    end
end

% 文件写入函数
function writeFile(data, saveFullPath)
    [~, ~, ext] = fileparts(saveFullPath);
    switch lower(ext)
        case '.xlsx'
            writetable(data, saveFullPath);
        case '.csv'
            writetable(data, saveFullPath);
        case '.txt'
            writetable(data, saveFullPath, 'Delimiter', '\t');
        otherwise
            error('不支持的保存格式');
    end
end
