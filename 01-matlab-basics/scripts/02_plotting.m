%% 章節 01-2：繪圖
% 2D 多曲線、subplot、3D 表面、註解與圖例
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% 1. 多條曲線 + 圖例
fig = figure('Visible', 'off', 'Position', [0 0 800 500]);
t = linspace(0, 2*pi, 200);
plot(t, sin(t), 'b-', ...
     t, sin(2*t), 'r--', ...
     t, sin(3*t), 'k-.');
xlabel('t'); ylabel('y');
title('多條曲線一次畫');
legend({'sin(t)','sin(2t)','sin(3t)'}, 'Location', 'southwest');
xlim([0, 2*pi]);
save_png(fig, fullfile(out_dir, '02_multi_curves.png'));

%% 2. subplot：把不同視圖塞同一張圖
fig = figure('Visible', 'off', 'Position', [0 0 1000 700]);
t = linspace(0, 4*pi, 500);
y = exp(-0.2*t) .* sin(2*t);    % 阻尼正弦

subplot(2,2,1);
plot(t, y);
xlabel('t'); ylabel('y(t)');
title('時間域');

subplot(2,2,2);
plot(y(1:end-1), diff(y)/(t(2)-t(1)));
xlabel('y'); ylabel('dy/dt');
title('相平面 (近似)');

subplot(2,2,3);
Y = fft(y);
f = (0:length(y)-1) / (t(end)-t(1));
plot(f(1:floor(end/2)), abs(Y(1:floor(end/2))));
xlabel('頻率'); ylabel('|FFT|');
xlim([0, 1]);
title('頻率譜');

subplot(2,2,4);
semilogy(t, abs(y) + 1e-6);
xlabel('t'); ylabel('|y| (log)');
title('對數縱軸：看包絡');

sgtitle('阻尼正弦的四種視角');
save_png(fig, fullfile(out_dir, '02_subplots.png'));

%% 3. 3D 表面
fig = figure('Visible', 'off', 'Position', [0 0 800 600]);
[X, Y] = meshgrid(-3:0.15:3, -3:0.15:3);
Z = peaks(X, Y);
surf(X, Y, Z, 'EdgeColor', 'none');
colormap(turbo);
colorbar;
xlabel('x'); ylabel('y'); zlabel('z');
title('peaks 函式 - 三維表面');
view(45, 30);
save_png(fig, fullfile(out_dir, '02_surf_peaks.png'));

%% 4. 註解：箭頭與文字
fig = figure('Visible', 'off', 'Position', [0 0 800 500]);
t = linspace(0, 2*pi, 200);
y = sin(t) .* exp(-0.3*t);
plot(t, y, 'LineWidth', 2);
xlabel('t'); ylabel('y');
title('阻尼振盪 - 標出第一個極小值');

% 找第一個極小值
[ymin, idx] = min(y);
hold on;
plot(t(idx), ymin, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
text(t(idx)+0.2, ymin, ...
     sprintf('  極小值：(%.2f, %.3f)', t(idx), ymin), ...
     'FontSize', 11);
xlim([0, 2*pi]);
save_png(fig, fullfile(out_dir, '02_annotation.png'));
