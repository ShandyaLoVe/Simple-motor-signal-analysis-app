% % function combined_signal_analysis()
% 主函数，用于选择分析类型

% 创建主界面
mainFig = uifigure('Name', '信号分析系统', 'Position', [100, 100, 300, 300]);

% 信号读取按钮
btnRead = uibutton(mainFig, 'push', 'Text', '信号读取', 'Position', [75, 170, 150, 30]);
btnRead.ButtonPushedFcn = @(~,~) signal_reading_GUI();

% 信号预处理按钮
btnPreprocess = uibutton(mainFig, 'push', 'Text', '信号预处理', 'Position', [75, 120, 150, 30]);
btnPreprocess.ButtonPushedFcn = @(~,~) signal_preprocessing_GUI();

% 振动信号分析按钮
btnVibration = uibutton(mainFig, 'push', 'Text', '振动信号分析', 'Position', [75, 70, 150, 30]);
btnVibration.ButtonPushedFcn = @(~,~) vibration_analysis_GUI();

% 噪声信号分析按钮
btnNoise = uibutton(mainFig, 'push', 'Text', '噪声信号分析', 'Position', [75, 20, 150, 30]);
btnNoise.ButtonPushedFcn = @(~,~) noise_signal_processing_GUI();
end

% 信号读取 GUI
function signal_reading_GUI()
    % 创建 GUI 界面
    fig = uifigure('Name', '信号读取', 'Position', [100, 100, 700, 500]);

    % 文件选择按钮
    btnLoad = uibutton(fig, 'push', 'Text', '选择文件', 'Position', [50, 400, 100, 30]);
    lblFile = uilabel(fig, 'Text', '未选择文件', 'Position', [170, 400, 450, 30], 'HorizontalAlignment', 'left');
    btnLoad.ButtonPushedFcn = @(~,~) loadFile(lblFile);

    % 信号类型选择
    uilabel(fig, 'Text', '信号类型:', 'Position', [50, 350, 100, 30]);
    signalTypeDropdown = uidropdown(fig, 'Items', {'振动和噪声信号', '系统激励与响应信号'}, 'Position', [150, 350, 200, 30]);

    % 输入截取区间
    uilabel(fig, 'Text', '起始时间(s):', 'Position', [50, 300, 100, 30]);
    startTime = uieditfield(fig, 'numeric', 'Position', [150, 300, 100, 30]);
    uilabel(fig, 'Text', '结束时间(s):', 'Position', [280, 300, 100, 30]);
    endTime = uieditfield(fig, 'numeric', 'Position', [380, 300, 100, 30]);

    % 截取和保存按钮
    btnSave = uibutton(fig, 'push', 'Text', '截取并保存', 'Position', [50, 250, 100, 30]);
    lblSave = uilabel(fig, 'Text', '', 'Position', [170, 250, 450, 30], 'HorizontalAlignment', 'left');
    btnSave.ButtonPushedFcn = @(~,~) processAndSave(lblFile, signalTypeDropdown, startTime, endTime, lblSave, fig);
    
    function loadFile(lblFile)
        % 打开文件选择对话框
        [fileName, filePath] = uigetfile({'*.xlsx;*.csv;*.txt', 'Supported Files (*.xlsx, *.csv, *.txt)'}, '选择文件');
        if fileName == 0
            return; % 用户取消操作
        end
        lblFile.Text = fullfile(filePath, fileName);
    end

    function processAndSave(lblFile, signalTypeDropdown, startTimeField, endTimeField, lblSave, fig)
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
        data = readFile(filePath, signalTypeDropdown.Value);
    
        % 截取信号
        time = data{:, 1};
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
end

% 信号预处理 GUI
function signal_preprocessing_GUI()
    % 创建 GUI 界面
    fig = uifigure('Name', '信号预处理', 'Position', [100, 100, 700, 500]);

    % 文件选择按钮
    btnLoad = uibutton(fig, 'push', 'Text', '选择文件', 'Position', [50, 400, 100, 30]);
    lblFile = uilabel(fig, 'Text', '未选择文件', 'Position', [170, 400, 450, 30], 'HorizontalAlignment', 'left');
    btnLoad.ButtonPushedFcn = @(~,~) loadFile(lblFile);

    % 信号类型选择
    uilabel(fig, 'Text', '信号类型:', 'Position', [50, 350, 100, 30]);
    signalTypeDropdown = uidropdown(fig, 'Items', {'振动和噪声信号', '系统激励与响应信号'}, 'Position', [150, 350, 200, 30]);

    % 重采样模块
    uilabel(fig, 'Text', '重采样倍率:', 'Position', [50, 300, 100, 30]);
    resampleFactor = uieditfield(fig, 'numeric', 'Position', [150, 300, 100, 30]);
    btnResample = uibutton(fig, 'push', 'Text', '重采样', 'Position', [50, 250, 100, 30]);
    btnResample.ButtonPushedFcn = @(~,~) resampleSignal(lblFile, signalTypeDropdown, resampleFactor, fig);

    % 时域特征值计算
    btnStats = uibutton(fig, 'push', 'Text', '计算时域特征', 'Position', [50, 200, 100, 30]);
    lblStats = uilabel(fig, 'Text', '', 'Position', [170, 200, 450, 60], 'HorizontalAlignment', 'left');
    btnStats.ButtonPushedFcn = @(~,~) computeStats(lblFile, signalTypeDropdown, lblStats, fig);

    % 去均值按钮
    btnDemean = uibutton(fig, 'push', 'Text', '去均值', 'Position', [50, 150, 100, 30]);
    btnDemean.ButtonPushedFcn = @(~,~) demeanSignal(lblFile, signalTypeDropdown, fig);

    % 预滤波按钮
    btnFilter = uibutton(fig, 'push', 'Text', '预滤波', 'Position', [50, 100, 100, 30]);
    btnFilter.ButtonPushedFcn = @(~,~) filterSignal(lblFile, signalTypeDropdown, fig);
    
    function loadFile(lblFile)
        % 打开文件选择对话框
        [fileName, filePath] = uigetfile({'*.xlsx;*.csv;*.txt', 'Supported Files (*.xlsx, *.csv, *.txt)'}, '选择文件');
        if fileName == 0
            return; % 用户取消操作
        end
        lblFile.Text = fullfile(filePath, fileName);
    end
    
    function resampleSignal(lblFile, signalTypeDropdown, resampleFactorField, fig)
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
        data = readFile(filePath, signalTypeDropdown.Value);
    
        % 获取原始信号和时间
        time = data{:, 1};
        signals = data{:, 2:end};
    
        % 计算原始采样率
        originalFs = 1 / mean(diff(time));
        newFs = originalFs * resampleFactor;
    
        % 重采样
        timeResampled = linspace(min(time), max(time), round(length(time) * resampleFactor));
        signalsResampled = interp1(time, signals, timeResampled, 'linear');
    
        % 创建新的表，并保存结果
        resampledData = array2table([timeResampled', signalsResampled], ...
            'VariableNames', data.Properties.VariableNames);
    
        % 保存文件
        [saveFile, savePath] = uiputfile({'*.xlsx', 'Excel Files (*.xlsx)'; '*.csv', 'CSV Files (*.csv)'; '*.txt', 'Text Files (*.txt)'}, '保存重采样信号为');
        if saveFile == 0
            return; % 用户取消保存操作
        end
        saveFullPath = fullfile(savePath, saveFile);
        writeFile(resampledData, saveFullPath);
        uialert(fig, ['文件已保存至: ', saveFullPath], '成功');
    end
    
    function computeStats(lblFile, signalTypeDropdown, lblStats, fig)
        % 检查文件是否已选择
        if strcmp(lblFile.Text, '未选择文件')
            uialert(fig, '请先选择文件', '错误');
            return;
        end
    
        % 读取文件
        filePath = lblFile.Text;
        data = readFile(filePath, signalTypeDropdown.Value);
    
        % 获取信号
        signal = data{:, 2}; % 假设以第一列信号为分析对象
    
        % 计算时域特征
        maxVal = max(signal);
        minVal = min(signal);
        peakToPeak = maxVal - minVal;
        meanVal = mean(signal);
    
        % 显示结果
        statsText = sprintf('最大值: %.3f\n最小值: %.3f\n峰峰值: %.3f\n均值: %.3f', maxVal, minVal, peakToPeak, meanVal);
        lblStats.Text = statsText;
    end
    
    function demeanSignal(lblFile, signalTypeDropdown, fig)
        % 检查文件是否已选择
        if strcmp(lblFile.Text, '未选择文件')
            uialert(fig, '请先选择文件', '错误');
            return;
        end
    
        % 读取文件
        filePath = lblFile.Text;
        data = readFile(filePath, signalTypeDropdown.Value);
    
        % 去均值
        signals = data{:, 2:end};
        demeanedSignals = signals - mean(signals);
        data{:, 2:end} = demeanedSignals;
    
        % 保存去均值后的数据
        [saveFile, savePath] = uiputfile({'*.xlsx', 'Excel Files (*.xlsx)'; '*.csv', 'CSV Files (*.csv)'; '*.txt', 'Text Files (*.txt)'}, '保存去均值信号为');
        if saveFile == 0
            return;
        end
        saveFullPath = fullfile(savePath, saveFile);
        writeFile(data, saveFullPath);
        uialert(fig, ['文件已保存至: ', saveFullPath], '成功');
    end
    
    function filterSignal(lblFile, signalTypeDropdown, fig)
        % 检查文件是否已选择
        if strcmp(lblFile.Text, '未选择文件')
            uialert(fig, '请先选择文件', '错误');
            return;
        end
    
        % 读取文件
        filePath = lblFile.Text;
        data = readFile(filePath, signalTypeDropdown.Value);
    
        % 获取信号
        signals = data{:, 2:end};
    
        % 设计滤波器（低通滤波器，截止频率 50 Hz）
        fs = 1 / mean(diff(data{:, 1})); % 采样率
        cutoffFreq = 50; % 截止频率
        [b, a] = butter(4, cutoffFreq / (fs / 2)); % 4 阶 Butterworth 滤波器
        filteredSignals = filtfilt(b, a, signals);
        data{:, 2:end} = filteredSignals;
    
        % 保存滤波后的数据
        [saveFile, savePath] = uiputfile({'*.xlsx', 'Excel Files (*.xlsx)'; '*.csv', 'CSV Files (*.csv)'; '*.txt', 'Text Files (*.txt)'}, '保存滤波信号为');
        if saveFile == 0
            return;
        end
        saveFullPath = fullfile(savePath, saveFile);
        writeFile(data, saveFullPath);
        uialert(fig, ['文件已保存至: ', saveFullPath], '成功');
    end
end

% 振动信号分析 GUI
function vibration_analysis_GUI()
% 创建主GUI界面
    fig = uifigure('Name', '振动信号分析工具', 'Position', [100, 100, 800, 600]);

    % 振动信号文件选择按钮
    uilabel(fig, 'Text', '选择振动信号文件：', 'Position', [20, 550, 160, 30]);
    vibrationFileEdit = uieditfield(fig, 'text', 'Position', [180, 550, 400, 30], 'Editable', 'off');
    vibrationFileButton = uibutton(fig, 'Text', '浏览', 'Position', [600, 550, 100, 30], ...
        'ButtonPushedFcn', @(btn, event) selectVibrationFile());

    % 激励信号文件选择按钮
    uilabel(fig, 'Text', '选择激励信号文件：', 'Position', [20, 500, 160, 30]);
    excitationFileEdit = uieditfield(fig, 'text', 'Position', [180, 500, 400, 30], 'Editable', 'off');
    excitationFileButton = uibutton(fig, 'Text', '浏览', 'Position', [600, 500, 100, 30], ...
        'ButtonPushedFcn', @(btn, event) selectExcitationFile());

    % 分析按钮
    analyzeButton = uibutton(fig, 'Text', '开始分析', 'Position', [250, 450, 100, 30], ...
        'ButtonPushedFcn', @(btn, event) startAnalysis());

    % 图形选择下拉菜单
    uilabel(fig, 'Text', '选择图形类型：', 'Position', [20, 400, 100, 30]);
    plotTypeDropDown = uidropdown(fig, 'Position', [130, 400, 200, 30], ...
        'Items', {'频谱分析', '功率谱分析', '自相关分析', '互相关分析', '传递函数'}, ...
        'Value', '频谱分析');

    % 结果显示区域
    ax = uiaxes(fig, 'Position', [50, 50, 700, 350]);
    ax.Title.String = '分析结果';
    ax.XLabel.String = 'X轴';
    ax.YLabel.String = 'Y轴';

    % 定义全局变量用于存储数据
    vibration_data = [];
    excitation_data = [];
    Fs = 0;

    % 振动信号文件选择回调函数
    function selectVibrationFile()
        [fileName, filePath] = uigetfile({'*.xlsx;*.csv', 'Supported Files (*.xlsx, *.csv)'}, '选择振动信号文件');
        if fileName == 0
            return; % 用户取消选择文件
        end
        vibrationFileEdit.Value = fullfile(filePath, fileName);
    end

    % 激励信号文件选择回调函数
    function selectExcitationFile()
        [fileName, filePath] = uigetfile({'*.xlsx;*.csv', 'Supported Files (*.xlsx, *.csv)'}, '选择激励信号文件');
        if fileName == 0
            return; % 用户取消选择文件
        end
        excitationFileEdit.Value = fullfile(filePath, fileName);
    end

    % 开始分析回调函数
    function startAnalysis()
        % 获取输入的文件路径
        vibration_file_path = vibrationFileEdit.Value;
        excitation_file_path = excitationFileEdit.Value;
        
        % 检查文件是否选择
        if isempty(vibration_file_path) || isempty(excitation_file_path)
            uialert(fig, '请先选择振动信号文件和激励信号文件！', '错误', 'Icon', 'error');
            return;
        end
        
        % 读取振动信号数据
        try
            vibration_data = readtable(vibration_file_path);
        catch
            uialert(fig, '无法读取振动信号数据！请检查文件路径和格式。', '错误', 'Icon', 'error');
            return;
        end
        
        % 读取激励信号数据
        try
            excitation_data = readtable(excitation_file_path);
        catch
            uialert(fig, '无法读取激励信号数据！请检查文件路径和格式。', '错误', 'Icon', 'error');
            return;
        end

        % 确保信号数据包含必需的列
        if ~all(ismember({'Time_seconds', 'Sound_pressure_PASCAL', 'Acceleration_in_meters_per_second'}, vibration_data.Properties.VariableNames)) || ...
           ~all(ismember({'Time_in_s', 'Excitation_force_signal', 'Vibration_acceleration_signal'}, excitation_data.Properties.VariableNames))
            uialert(fig, '输入文件格式错误！请确保文件包含正确的列名。', '错误', 'Icon', 'error');
            return;
        end

        % 提取信号数据
        time_vibration = vibration_data.Time_seconds;
        sound_pressure = vibration_data.Sound_pressure_PASCAL;
        acceleration = vibration_data.Acceleration_in_meters_per_second;
        time_excitation = excitation_data.Time_in_s;
        excitation = excitation_data.Excitation_force_signal;
        response = excitation_data.Vibration_acceleration_signal;

        % 采样频率
        Fs = 1 / mean(diff(time_vibration));

        % 根据选择的图形类型进行分析并绘图
        cla(ax);
        switch plotTypeDropDown.Value
            case '频谱分析'
                plotSpectrum(ax, time_vibration, excitation, response);
            case '功率谱分析'
                plotPowerSpectrum(ax, excitation, response, Fs);
            case '自相关分析'
                plotAutoCorrelation(ax, excitation, response);
            case '互相关分析'
                plotCrossCorrelation(ax, excitation, response);
            case '传递函数'
                plotTransferFunction(ax, excitation, response, Fs);
        end
    end

    % 频谱分析
% 频谱分析
function plotSpectrum(ax, time, excitation, response)
    % 获取信号长度
    N = length(time);
    
    % 计算频率轴，确保它与信号长度一致
    f = (0:N-1) * (Fs / N); % 频率轴，保证计算无误
    
    % 计算激励信号和响应信号的FFT
    Excitation_spectrum = abs(fft(excitation, N));  % 对激励信号进行FFT
    Response_spectrum = abs(fft(response, N));  % 对响应信号进行FFT

    % 绘图，避免越界
    plot(ax, f(1:floor(N/2)), Excitation_spectrum(1:floor(N/2)), 'r');  % 只取前一半频率
    hold(ax, 'on');
    plot(ax, f(1:floor(N/2)), Response_spectrum(1:floor(N/2)), 'b');  % 只取前一半频率
    hold(ax, 'off');
    
    % 设置图例和标签
    legend(ax, '激励信号', '响应信号');
    ax.Title.String = '频谱分析';
    ax.XLabel.String = '频率 (Hz)';
    ax.YLabel.String = '幅度';
    xlim(ax, [0, Fs/2]);
end

    % 功率谱分析
    function plotPowerSpectrum(ax, excitation, response, Fs)
        [pxx_ex, f_ex] = pwelch(excitation, [], [], [], Fs);
        [pxx_res, f_res] = pwelch(response, [], [], [], Fs);

        % 绘图
        semilogx(ax, f_ex, 10*log10(pxx_ex), 'r');
        hold(ax, 'on');
        semilogx(ax, f_res, 10*log10(pxx_res), 'b');
        hold(ax, 'off');
        legend(ax, '激励信号', '响应信号');
        ax.Title.String = '功率谱分析';
        ax.XLabel.String = '频率 (Hz)';
        ax.YLabel.String = '功率谱 (dB/Hz)';
        xlim(ax, [0, Fs/2]);
    end

    % 自相关分析
    function plotAutoCorrelation(ax, excitation, response)
        auto_corr_ex = xcorr(excitation, 'biased');
        auto_corr_res = xcorr(response, 'biased');

        % 绘图
        plot(ax, auto_corr_ex, 'r');
        hold(ax, 'on');
        plot(ax, auto_corr_res, 'b');
        hold(ax, 'off');
        legend(ax, '激励信号', '响应信号');
        ax.Title.String = '自相关分析';
        ax.XLabel.String = '时延 (s)';
        ax.YLabel.String = '自相关';
    end

    % 互相关分析
    function plotCrossCorrelation(ax, excitation, response)
        cross_corr = xcorr(excitation, response, 'biased');

        % 绘图
        plot(ax, cross_corr, 'k');
        ax.Title.String = '互相关分析';
        ax.XLabel.String = '时延 (s)';
        ax.YLabel.String = '互相关';
    end

    % 传递函数
    function plotTransferFunction(ax, excitation, response, Fs)
        N = length(excitation);
        Excitation_fft = fft(excitation);
        Response_fft = fft(response);
        H = Response_fft ./ Excitation_fft; % 传递函数 H(f)
        f = (0:N-1) * (Fs / N); % 频率轴

        % 绘图
        semilogx(ax, f(1:N/2), abs(H(1:N/2)), 'r');
        hold(ax, 'on');
        semilogx(ax, f(1:N/2), angle(H(1:N/2)), 'b');
        hold(ax, 'off');
        legend(ax, '幅频响应', '相频响应');
        ax.Title.String = '传递函数分析';
        ax.XLabel.String = '频率 (Hz)';
        ax.YLabel.String = '响应';
        xlim(ax, [0, Fs/2]);
    end
end

% 噪声信号分析 GUI
function noise_signal_processing_GUI()
% 创建 GUI 界面
    fig = uifigure('Name', '噪声信号处理', 'Position', [100, 100, 600, 600]);
    
    % 文件选择按钮
    btnLoad = uibutton(fig, 'push', 'Text', '选择文件', 'Position', [50 500 100 30]);
    lblFile = uilabel(fig, 'Text', '未选择文件', 'Position', [170 500 350 30], 'HorizontalAlignment', 'left');
    btnLoad.ButtonPushedFcn = @(~,~) loadFile(lblFile);
    
    % 频谱分析按钮
    btnSpectrum = uibutton(fig, 'push', 'Text', '频谱分析', 'Position', [50 450 100 30]);
    btnSpectrum.ButtonPushedFcn = @(~,~) spectrumAnalysis(lblFile, fig);
    
    % 功率谱分析按钮
    btnPowerSpectrum = uibutton(fig, 'push', 'Text', '功率谱分析', 'Position', [50 400 100 30]);
    btnPowerSpectrum.ButtonPushedFcn = @(~,~) powerSpectrumAnalysis(lblFile, fig);
    
    % 自相关分析按钮
    btnAutoCorr = uibutton(fig, 'push', 'Text', '自相关分析', 'Position', [50 350 100 30]);
    btnAutoCorr.ButtonPushedFcn = @(~,~) autoCorrelationAnalysis(lblFile, fig);
    
    % 互相关分析按钮
    btnCrossCorr = uibutton(fig, 'push', 'Text', '互相关分析', 'Position', [50 300 100 30]);
    btnCrossCorr.ButtonPushedFcn = @(~,~) crossCorrelationAnalysis(lblFile, fig);
    
    % A计权声压级计算按钮
    btnAWeighting = uibutton(fig, 'push', 'Text', 'A计权声压级', 'Position', [50 250 100 30]);
    btnAWeighting.ButtonPushedFcn = @(~,~) AWeighting(lblFile, fig);
    
    % 1/3倍频程分析按钮
    btnThirdOctave = uibutton(fig, 'push', 'Text', '1/3倍频程分析', 'Position', [50 200 100 30]);
    btnThirdOctave.ButtonPushedFcn = @(~,~) thirdOctaveAnalysis(lblFile, fig);

    % 绘图区域
    ax = uiaxes(fig, 'Position', [250 50, 300, 500]);
    
    function loadFile(lblFile)
        % 打开文件选择对话框
        [fileName, filePath] = uigetfile({'*.xlsx;*.csv;*.txt', 'Supported Files (*.xlsx, *.csv, *.txt)'}, '选择文件');
        if fileName == 0
            return; % 用户取消操作
        end
        lblFile.Text = fullfile(filePath, fileName);
    end
    
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
        plot(ax, f(1:n/2), Y);
        title(ax, '噪声信号频谱');
        xlabel(ax, '频率 (Hz)');
        ylabel(ax, '幅值');
        xlim(ax, [0, fs/2]);
    end
    
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
        plot(ax, Freq, 10*log10(Pxx)); % 以 dB 绘制功率谱
        title(ax, '噪声信号功率谱');
        xlabel(ax, '频率 (Hz)');
        ylabel(ax, '功率 (dB)');
        xlim(ax, [0, fs/2]);
    end
    
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
        plot(ax, lag, acor);
        title(ax, '自相关分析');
        xlabel(ax, '滞后');
        ylabel(ax, '自相关系数');
    end
    
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
        plot(ax, lag, xcorr_val);
        title(ax, '互相关分析');
        xlabel(ax, '滞后');
        ylabel(ax, '互相关系数');
    end
    
    function AWeighting(lblFile, fig)
        % 检查文件是否已选择
        if strcmp(lblFile.Text, '未选择文件')
            uialert(fig, '请先选择文件', '错误');
            return;
        end
        
        % 读取文件
        filePath = lblFile.Text;
        data = readFile(filePath);
        
        % 获取信号和采样率
        signal = data.Sound_pressure_PASCAL;
        fs = 1 / mean(diff(data.Time_seconds)); % 采样率
        
        % A计权滤波器
        f = (20:fs/2); % 频率范围从 20 Hz 到 Nyquist 频率
        A_weighting_filter = 10.^(( -20*log10(f / 1000) ) / 2); % A计权曲线
        
        % 计算声压级
        signal_rms = rms(signal);
        A_weighted_signal = signal .* A_weighting_filter;
        A_weighted_rms = rms(A_weighted_signal);
        
        % 计算声压级
        Lp = 20 * log10(A_weighted_rms / 20e-6); % A计权声压级，单位dB
        uialert(fig, sprintf('A计权声压级: %.2f dB', Lp), '结果');
    end
    
    function thirdOctaveAnalysis(lblFile, fig)
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
        fs = 1 / mean(diff(data.Time_seconds)); % 采样
            % 获取信号
        signal = data.Sound_pressure_PASCAL;  % 或者选择适当的信号字段
        
        % 设置1/3倍频程的频率范围
        octaveBands = logspace(log10(20), log10(fs / 2), 30);  % 1/3倍频程频率范围
        
        % 计算每个频带的幅值
        [Pxx, Freq] = pwelch(signal, [], [], octaveBands, fs);
        
        % 绘制1/3倍频程分析图
        plot(ax, Freq, 10*log10(Pxx)); % 绘制以dB为单位的1/3倍频程功率谱
        title(ax, '1/3倍频程分析');
        xlabel(ax, '频率 (Hz)');
        ylabel(ax, '功率 (dB)');
        xlim(ax, [20, fs/2]);
    end
    
    % 文件读取函数 (共用)
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
end

% 文件读取函数 (共用)
function data = readFile(filePath, signalType)
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

% 检查信号类型
if nargin > 1
    switch signalType
        case '振动和噪声信号'
            requiredCols = {'Time_seconds', 'Sound_pressure_PASCAL', 'Acceleration_in_meters_per_second'};
        case '系统激励与响应信号'
            requiredCols = {'Time_in_s', 'Excitation_force_signal', 'Vibration_acceleration_signal'};
        otherwise
            error('未知的信号类型');
    end

    % 验证列是否存在
    if ~all(ismember(requiredCols, data.Properties.VariableNames))
        error('文件缺少必要的列: %s', strjoin(setdiff(requiredCols, data.Properties.VariableNames), ', '));
    end

    % 返回所需列
    data = data(:, requiredCols);
end
end

% 文件写入函数 (共用)
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