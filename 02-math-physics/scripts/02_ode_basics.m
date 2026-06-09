%% 章節 02-2：常微分方程數值解 (ode45)
% 工程上 95% 的 ODE 用 ode45 就夠用
% 重點：把高階 ODE 改寫成「狀態向量」一階系統
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% 1. 一階 ODE：dy/dt = -k*y (放射性衰變)
k_decay = 0.5;
f1 = @(t, y) -k_decay * y;

tspan = [0, 10];
y0 = 1.0;
[t, y] = ode45(f1, tspan, y0);

fig = figure('Visible', 'off', 'Position', [0 0 800 500]);
plot(t, y, 'b-', 'LineWidth', 2); hold on;
plot(t, exp(-k_decay*t), 'r--', 'LineWidth', 1.5);
xlabel('t'); ylabel('y');
title(sprintf('dy/dt = -%.1f y，數值 vs 解析', k_decay));
legend({'ode45 數值解', '解析解 e^{-kt}'}, 'Location', 'northeast');
save_png(fig, fullfile(out_dir, '02_ode_decay.png'));

%% 2. 二階 ODE：彈簧質量阻尼
% m*x'' + c*x' + k*x = 0
% 改寫：令 y1 = x, y2 = x'
%   y1' = y2
%   y2' = -(c/m)*y2 - (k/m)*y1
m = 1; c = 0.5; k = 4;

% 第一種寫法：anonymous function
f2 = @(t, y) [y(2);
              -(c/m)*y(2) - (k/m)*y(1)];

[t, Y] = ode45(f2, [0 20], [1; 0]);
% Y(:, 1) 是位置 x，Y(:, 2) 是速度 x'

fig = figure('Visible', 'off', 'Position', [0 0 1000 400]);
subplot(1,2,1);
plot(t, Y(:,1), 'b-', t, Y(:,2), 'r--', 'LineWidth', 2);
xlabel('t (s)'); ylabel('value');
legend({'位置 x(t)', '速度 x''(t)'});
title('彈簧質量阻尼：時間域');

subplot(1,2,2);
plot(Y(:,1), Y(:,2), 'k-', 'LineWidth', 1.5);
xlabel('位置 x'); ylabel('速度 x''');
title('相平面軌跡（往原點螺旋收斂）');
axis equal;
save_png(fig, fullfile(out_dir, '02_ode_spring.png'));

%% 3. 比較不同求解器：剛性 (stiff) 系統
% van der Pol oscillator，mu 大時為剛性問題
% x'' - mu*(1-x^2)*x' + x = 0
mu = 1000;
vdp = @(t, y) [y(2);
               mu*(1 - y(1)^2)*y(2) - y(1)];

% ode45 (非剛性) 對 mu=1000 會跑很慢
% ode15s (剛性) 適合
opts = odeset('RelTol', 1e-6, 'AbsTol', 1e-8);
tic;
[t_s, Y_s] = ode15s(vdp, [0, 3000], [2; 0], opts);
t_stiff = toc;
fprintf('ode15s 解 van der Pol (mu=%d)：%.3f 秒，%d 個時間點\n', ...
        mu, t_stiff, length(t_s));

fig = figure('Visible', 'off', 'Position', [0 0 900 500]);
plot(t_s, Y_s(:, 1), 'b-', 'LineWidth', 1.5);
xlabel('t'); ylabel('x(t)');
title(sprintf('van der Pol 振盪 (mu=%d，剛性問題，用 ode15s)', mu));
xlim([0, 3000]);
save_png(fig, fullfile(out_dir, '02_ode_vdp.png'));

%% 4. 事件偵測：拋體何時落地
% y'' = -g, 落地時 y = 0 停止
g_grav = 9.81;
projectile = @(t, s) [s(3); s(4); 0; -g_grav];   % [x; y; vx; vy]

% 事件函式：y=0 且 dy/dt<0 (下降中)，定義在 hitGround.m
opts = odeset('Events', @hitGround);

s0 = [0; 0; 30; 30];   % 從原點以 30 m/s 水平、30 m/s 垂直射出
[t, S, te, se, ie] = ode45(projectile, [0, 10], s0, opts);

fprintf('落地時間 t = %.3f s, x = %.2f m\n', te, se(1));

fig = figure('Visible', 'off', 'Position', [0 0 800 500]);
plot(S(:,1), S(:,2), 'b-', 'LineWidth', 2); hold on;
plot(se(1), se(2), 'ro', 'MarkerSize', 12, 'LineWidth', 2);
text(se(1)-12, 2, sprintf('落地 t=%.2fs, x=%.1fm', te, se(1)), 'FontSize', 11);
yline(0, 'k-');
xlabel('x (m)'); ylabel('y (m)');
title('拋體軌跡（用 ode45 事件偵測落地）');
axis equal;
save_png(fig, fullfile(out_dir, '02_ode_event.png'));
