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
    signal = data.Sound_pressure_PASCAL; % 这里以 Sound_pressure_PASCAL 为示例信号
    originalFs = 1 / mean(diff(time)); % 原始采样率
    newFs = originalFs * resampleFactor; % 新采样率
    
    % 重采样
    [newSignal, newTime] = resample(signal, time, newFs);
    
    % 创建新的表，并保存结果
    resampledData = table(newTime, newSignal, 'VariableNames', {'Time_seconds', 'Sound_pressure_PASCAL'});
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
