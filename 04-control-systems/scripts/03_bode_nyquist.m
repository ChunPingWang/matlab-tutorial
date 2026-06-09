%% 章節 04-3：Bode 與 Nyquist 圖
% 頻域分析三大主角：bode / nyquist / margin
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% 系統：典型受控對象（plant）
G = tf(10, [1, 3, 2, 0]);     % 含積分器，三階
% 1/[s*(s+1)*(s+2)] 形式，常見於馬達位置控制

%% Bode 圖
fig = figure('Visible', 'off', 'Position', [0 0 900 700]);
bode(G, {0.1, 100});
grid on;
title('Bode 圖：頻率響應的標準視覺化');
save_png(fig, fullfile(out_dir, '03_bode.png'));

%% Bode + 穩定餘裕 (margin)
fig = figure('Visible', 'off', 'Position', [0 0 900 700]);
margin(G);
grid on;
save_png(fig, fullfile(out_dir, '03_bode_margin.png'));

[Gm, Pm, Wcg, Wcp] = margin(G);
fprintf('增益餘裕 GM = %.2f dB （在 %.2f rad/s）\n', 20*log10(Gm), Wcg);
fprintf('相位餘裕 PM = %.2f deg（在 %.2f rad/s）\n', Pm, Wcp);
fprintf('GM > 6dB、PM > 30 度通常算「夠穩」\n');

%% Nyquist 圖
fig = figure('Visible', 'off', 'Position', [0 0 700 700]);
nyquist(G);
title('Nyquist 圖：判穩看「是否繞 -1 點」');
save_png(fig, fullfile(out_dir, '03_nyquist.png'));

%% 三個典型 plant 的 Bode 比較
fig = figure('Visible', 'off', 'Position', [0 0 1000 800]);
G1 = tf(1, [1, 1]);                    % 1 階 lowpass
G2 = tf(1, [1, 0.2, 1]);               % 2 階 lightly damped
G3 = tf([0.1, 1], [1, 1, 1]);          % lead 補償器
bode(G1, G2, G3, {0.01, 100});
legend({'1/(s+1)', '1/(s^2+0.2s+1)', '(0.1s+1)/(s^2+s+1)'}, ...
       'Location', 'southwest');
title('三種典型動態的 Bode 形狀');
grid on;
save_png(fig, fullfile(out_dir, '03_bode_compare.png'));
