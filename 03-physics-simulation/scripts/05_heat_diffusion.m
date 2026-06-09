%% 章節 03-5：1D 熱傳導方程式
% PDE: u_t = alpha * u_xx
% 用 pdepe 解（MATLAB 內建一維 PDE 求解器）
% 物理：長度 L 的金屬棒，兩端固定 0°C，初始中間 100°C，看熱怎麼擴散
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% 參數
alpha = 1e-4;   % 熱擴散係數 m^2/s（典型金屬約 1e-4）
L = 0.1;        % 棒長 10cm
T_end = 60;     % 模擬 60 秒（特徵時間 L^2/alpha = 100s 的同尺度）

x = linspace(0, L, 80);
t = linspace(0, T_end, 80);

%% pdepe 需要三個函式：pde, ic, bc
% u_t = alpha * u_xx  改寫成 c*u_t = (x^m * f)_x / x^m + s
% 此處 m=0 (cartesian), c=1, f=alpha*u_x, s=0
sol = pdepe(0, ...
    @(x, t, u, dudx) deal(1, alpha*dudx, 0), ...
    @(x) 100 * (x > 0.4*L & x < 0.6*L), ...
    @(xl, ul, xr, ur, t) deal(ul, 0, ur, 0), ...
    x, t);

U = sol(:, :, 1);   % U(t_idx, x_idx)

%% 1. Heatmap：時間 x 空間
fig = figure('Visible', 'off', 'Position', [0 0 900 500]);
imagesc(x*100, t, U);
set(gca, 'YDir', 'normal');
colormap(hot); colorbar;
xlabel('x (cm)'); ylabel('t (s)');
title('1D 熱傳導：兩端冷卻 0°C，中央初始 100°C');
save_png(fig, fullfile(out_dir, '05_heat_heatmap.png'));

%% 2. 幾個時刻的快照
fig = figure('Visible', 'off', 'Position', [0 0 900 500]);
times_pick = [0, 2, 5, 15, 60];
colors = lines(length(times_pick));
for k = 1:length(times_pick)
    [~, idx] = min(abs(t - times_pick(k)));
    plot(x*100, U(idx, :), 'Color', colors(k,:), 'LineWidth', 2, ...
         'DisplayName', sprintf('t = %d s', times_pick(k))); hold on;
end
xlabel('x (cm)'); ylabel('溫度 (°C)');
title('溫度分布隨時間擴散');
legend('Location', 'northeast');
save_png(fig, fullfile(out_dir, '05_heat_snapshots.png'));

%% 3. 中央點溫度衰減
[~, x_mid] = min(abs(x - L/2));
fig = figure('Visible', 'off', 'Position', [0 0 900 400]);
semilogy(t, U(:, x_mid), 'b-', 'LineWidth', 2);
xlabel('t (s)'); ylabel('中央點溫度 (°C, log)');
title('中央點溫度隨時間 (對數縱軸看指數衰減特徵)');
save_png(fig, fullfile(out_dir, '05_heat_center.png'));
