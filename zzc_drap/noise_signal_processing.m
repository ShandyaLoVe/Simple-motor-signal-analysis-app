function noise_signal_processing()
    % 创建 GUI 界面
    fig = uifigure('Name', '噪声信号处理', 'Position', [100 100 600 600]);
    
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
end

% 文件加载函数
function loadFile(lblFile)
    % 打开文件选择对话框
    [fileName, filePath] = uigetfile({'*.xlsx;*.csv;*.txt', 'Supported Files (*.xlsx, *.csv, *.txt)'}, '选择文件');
    if fileName == 0
        return; % 用户取消操作
    end
    lblFile.Text = fullfile(filePath, fileName);
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
    title('噪声信号频谱');
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
    title('噪声信号功率谱');
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

% A计权声压级计算
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

% 1/3倍频程分析
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
    figure;
    semilogx(Freq, 10*log10(Pxx)); % 绘制以dB为单位的1/3倍频程功率谱
    title('1/3倍频程分析');
    xlabel('频率 (Hz)');
    ylabel('功率 (dB)');
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
