function signal_processing()
    % 创建 GUI 界面
    fig = uifigure('Name', '信号读取与处理', 'Position', [100 100 600 400]);
    
    % 文件选择按钮
    btnLoad = uibutton(fig, 'push', 'Text', '选择文件', 'Position', [50 300 100 30]);
    lblFile = uilabel(fig, 'Text', '未选择文件', 'Position', [170 300 350 30], 'HorizontalAlignment', 'left');
    btnLoad.ButtonPushedFcn = @(~,~) loadFile(lblFile);
    
    % 输入截取区间
    uilabel(fig, 'Text', '起始时间(s):', 'Position', [50 250 100 30]);
    startTime = uieditfield(fig, 'numeric', 'Position', [150 250 100 30]);
    uilabel(fig, 'Text', '结束时间(s):', 'Position', [280 250 100 30]);
    endTime = uieditfield(fig, 'numeric', 'Position', [380 250 100 30]);
    
    % 截取和保存按钮
    btnSave = uibutton(fig, 'push', 'Text', '截取并保存', 'Position', [50 200 100 30]);
    lblSave = uilabel(fig, 'Text', '', 'Position', [170 200 350 30], 'HorizontalAlignment', 'left');
    btnSave.ButtonPushedFcn = @(~,~) processAndSave(lblFile, startTime, endTime, lblSave);
end

function loadFile(lblFile)
    % 打开文件选择对话框
    [fileName, filePath] = uigetfile({'*.xlsx;*.csv;*.txt', 'Supported Files (*.xlsx, *.csv, *.txt)'}, '选择文件');
    if fileName == 0
        return; % 用户取消操作
    end
    lblFile.Text = fullfile(filePath, fileName);
end

function processAndSave(lblFile, startTimeField, endTimeField, lblSave)
    % 检查文件是否已选择
    if strcmp(lblFile.Text, '未选择文件')
        uialert(gcf, '请先选择文件', '错误');
        return;
    end
    
    % 获取截取时间区间
    startTime = startTimeField.Value;
    endTime = endTimeField.Value;
    if isempty(startTime) || isempty(endTime) || startTime >= endTime
        uialert(gcf, '请正确输入起始和结束时间', '错误');
        return;
    end
    
    % 读取文件
    filePath = lblFile.Text;
    [~, ~, ext] = fileparts(filePath);
    switch lower(ext)
        case '.xlsx'
            data = readtable(filePath);
        case '.csv'
            data = readtable(filePath);
        case '.txt'
            data = readtable(filePath, 'Delimiter', '\t');
        otherwise
            uialert(gcf, '不支持的文件格式', '错误');
            return;
    end
    
    % 检查文件是否包含必要列
    if ~all(ismember({'Time_seconds', 'Sound_pressure_PASCAL', 'Acceleration_in_meters_per_second'}, data.Properties.VariableNames))
        uialert(gcf, '文件缺少必要的列', '错误');
        return;
    end
    
    % 截取信号
    time = data.Time_seconds;
    idx = (time >= startTime) & (time <= endTime);
    if ~any(idx)
        uialert(gcf, '指定时间范围内没有数据', '错误');
        return;
    end
    croppedData = data(idx, :);
    
    % 保存截取后的数据
    [saveFile, savePath] = uiputfile({'*.xlsx', 'Excel Files (*.xlsx)'; '*.csv', 'CSV Files (*.csv)'; '*.txt', 'Text Files (*.txt)'}, '保存文件为');
    if saveFile == 0
        return; % 用户取消保存操作
    end
    saveFullPath = fullfile(savePath, saveFile);
    [~, ~, saveExt] = fileparts(saveFullPath);
    switch lower(saveExt)
        case '.xlsx'
            writetable(croppedData, saveFullPath);
        case '.csv'
            writetable(croppedData, saveFullPath);
        case '.txt'
            writetable(croppedData, saveFullPath, 'Delimiter', '\t');
        otherwise
            uialert(gcf, '不支持的保存格式', '错误');
            return;
    end
    
    lblSave.Text = ['文件已保存至: ', saveFullPath];
end
