%% 章節 05-2：DC 馬達 PID 速度控制（Simulink）
% 包含：參考輸入、PID 控制器、Plant、回授、Scope
% 比較有 PID 與無 PID 的響應
clear; close all; bdclose all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');
model_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'models');
if ~exist(model_dir, 'dir'); mkdir(model_dir); end

modelName = 'motor_pid';
new_system(modelName);
open_system(modelName);

%% DC 馬達參數
J = 0.01; B = 0.1; Kt = 0.01; Kb = 0.01; R = 1;
num = Kt/R;
den_a = J;
den_b = B + Kt*Kb/R;

%% 加入方塊
% Reference (目標 1 rad/s)
add_block('simulink/Sources/Step', [modelName '/Ref'], ...
    'Position', [50, 100, 80, 130], ...
    'Time', '0', 'After', '1');

% Sum: ref - feedback
add_block('simulink/Math Operations/Sum', [modelName '/Error'], ...
    'Position', [130, 95, 160, 135], ...
    'Inputs', '+-');

% PID 控制器
add_block('simulink/Continuous/PID Controller', [modelName '/PID'], ...
    'Position', [200, 90, 260, 140], ...
    'P', '14.33', 'I', '260', 'D', '0');

% Plant: transfer function (Kt/R) / (J*s + B + Kt*Kb/R)
add_block('simulink/Continuous/Transfer Fcn', [modelName '/Motor'], ...
    'Position', [300, 90, 380, 140], ...
    'Numerator', mat2str(num), ...
    'Denominator', mat2str([den_a, den_b]));

% Scope
add_block('simulink/Sinks/Scope', [modelName '/Scope'], ...
    'Position', [430, 100, 460, 130]);

% To Workspace
add_block('simulink/Sinks/To Workspace', [modelName '/Out'], ...
    'Position', [430, 160, 470, 190], ...
    'VariableName', 'w_out', ...
    'SaveFormat', 'Structure With Time');

%% 連線
add_line(modelName, 'Ref/1', 'Error/1');
add_line(modelName, 'Error/1', 'PID/1');
add_line(modelName, 'PID/1', 'Motor/1');
add_line(modelName, 'Motor/1', 'Scope/1');
add_line(modelName, 'Motor/1', 'Out/1');
% 回授：Motor 輸出 -> Error(-) 端
add_line(modelName, 'Motor/1', 'Error/2', 'autorouting', 'on');

%% 模型設定
set_param(modelName, 'StopTime', '3', 'Solver', 'ode45');

%% 截圖
print('-s' + string(modelName), '-dpng', '-r150', fullfile(out_dir, '02_motor_pid_diagram.png'));

%% 存模型
save_system(modelName, fullfile(model_dir, [modelName '.slx']));

%% 跑模擬
simOut = sim(modelName);
w_pid = simOut.w_out.signals.values;
t_pid = simOut.w_out.time;

%% 對照：開迴路（直接餵 1V）
bdclose(modelName);

% 用 MATLAB 直接算
G = tf(num, [den_a, den_b]);
[w_ol, t_ol] = step(G, 3);

%% 畫對照圖
fig = figure('Visible', 'off', 'Position', [0 0 1000 500]);
plot(t_pid, w_pid, 'b-', 'LineWidth', 2.5); hold on;
plot(t_ol, w_ol, 'r--', 'LineWidth', 2);
yline(1, 'k:', '目標 1 rad/s');
xlabel('t (s)'); ylabel('\omega (rad/s)');
title('DC 馬達速度控制：有 PID vs 開迴路 1V');
legend({sprintf('Simulink PID 閉迴路'), '開迴路 1V 輸入'}, ...
       'Location', 'southeast');
save_png(fig, fullfile(out_dir, '02_motor_pid_response.png'));

fprintf('完成\n');
