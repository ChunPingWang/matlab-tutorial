%% 章節 05-1：用程式碼建立 Simulink 模型 - 彈簧質量阻尼
% Simulink 通常用 GUI 拉方塊，但所有操作都有對應的程式 API
% 對教學最大好處：模型完全可重現
clear; close all; bdclose all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');
model_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'models');
if ~exist(model_dir, 'dir'); mkdir(model_dir); end

modelName = 'smd_open';
new_system(modelName);
open_system(modelName);

% 物理參數
m = 1; c = 0.5; k = 4;

%% 加入方塊
% Step 輸入
add_block('simulink/Sources/Step', [modelName '/Step'], ...
    'Position', [50, 100, 80, 130], ...
    'Time', '0', 'After', '1');

% Sum 點：u - c*v - k*x
add_block('simulink/Math Operations/Sum', [modelName '/Sum'], ...
    'Position', [150, 95, 180, 135], ...
    'Inputs', '+--');

% Gain: 1/m
add_block('simulink/Math Operations/Gain', [modelName '/inv_m'], ...
    'Position', [220, 100, 260, 130], ...
    'Gain', num2str(1/m));

% Integrator x2：a -> v -> x
add_block('simulink/Continuous/Integrator', [modelName '/Int_v'], ...
    'Position', [300, 100, 330, 130]);
add_block('simulink/Continuous/Integrator', [modelName '/Int_x'], ...
    'Position', [370, 100, 400, 130]);

% Gain: c (阻尼)、k (彈簧)
add_block('simulink/Math Operations/Gain', [modelName '/c_gain'], ...
    'Position', [300, 180, 340, 210], ...
    'Gain', num2str(c), ...
    'Orientation', 'left');
add_block('simulink/Math Operations/Gain', [modelName '/k_gain'], ...
    'Position', [370, 230, 410, 260], ...
    'Gain', num2str(k), ...
    'Orientation', 'left');

% Scope 觀察位移
add_block('simulink/Sinks/Scope', [modelName '/Scope_x'], ...
    'Position', [440, 100, 470, 130]);

% To Workspace 把資料寫回 MATLAB 變數
add_block('simulink/Sinks/To Workspace', [modelName '/ToWS'], ...
    'Position', [440, 160, 480, 190], ...
    'VariableName', 'x_out', ...
    'SaveFormat', 'Structure With Time');

%% 連線
add_line(modelName, 'Step/1', 'Sum/1');
add_line(modelName, 'Sum/1', 'inv_m/1');
add_line(modelName, 'inv_m/1', 'Int_v/1');
add_line(modelName, 'Int_v/1', 'Int_x/1');
add_line(modelName, 'Int_x/1', 'Scope_x/1');
add_line(modelName, 'Int_x/1', 'ToWS/1');

% 回授：v -> c_gain -> Sum(-)
add_line(modelName, 'Int_v/1', 'c_gain/1', 'autorouting', 'on');
add_line(modelName, 'c_gain/1', 'Sum/2', 'autorouting', 'on');

% 回授：x -> k_gain -> Sum(-)
add_line(modelName, 'Int_x/1', 'k_gain/1', 'autorouting', 'on');
add_line(modelName, 'k_gain/1', 'Sum/3', 'autorouting', 'on');

%% 模型設定
set_param(modelName, 'StopTime', '15', 'Solver', 'ode45');

%% 截 block diagram 圖
print('-s' + string(modelName), '-dpng', '-r150', fullfile(out_dir, '01_smd_diagram.png'));
fprintf('Saved block diagram: 01_smd_diagram.png\n');

%% 儲存 .slx
save_system(modelName, fullfile(model_dir, [modelName '.slx']));
fprintf('Saved model: %s.slx\n', modelName);

%% 跑模擬
simOut = sim(modelName);
x = simOut.x_out.signals.values;
t = simOut.x_out.time;

%% 畫結果
fig = figure('Visible', 'off', 'Position', [0 0 900 500]);
plot(t, x, 'b-', 'LineWidth', 2);
yline(1/k, 'r--', sprintf('穩態 = 1/k = %.2f', 1/k));
xlabel('t (s)'); ylabel('位移 x');
title('Simulink 彈簧質量阻尼：對 1N 階躍的響應');
save_png(fig, fullfile(out_dir, '01_smd_response.png'));

bdclose(modelName);
fprintf('完成\n');
