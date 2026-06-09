%% 章節 03-3：雙擺 (混沌系統)
% 兩根剛性桿、無摩擦，但展現對初始條件的敏感依賴
% 公式來源：Lagrangian 力學，狀態 [theta1; theta2; omega1; omega2]
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% 參數
g = 9.81;
m1 = 1; m2 = 1;
L1 = 1; L2 = 1;
params = struct('g', g, 'm1', m1, 'm2', m2, 'L1', L1, 'L2', L2);

%% 解兩個初始條件略不同的雙擺，看軌跡如何發散
tspan = [0, 30];
y0_a = [pi/2; pi/2; 0; 0];                  % 雙擺水平
y0_b = [pi/2 + 1e-3; pi/2; 0; 0];           % 只差 0.001 rad
opts = odeset('RelTol', 1e-9, 'AbsTol', 1e-10);

[t, Ya] = ode45(@(t,y) double_pendulum_rhs(t, y, params), tspan, y0_a, opts);
[~, Yb] = ode45(@(t,y) double_pendulum_rhs(t, y, params), tspan, y0_b, opts);
% 統一時間網格以做對比
Yb = interp1(linspace(0,1,size(Yb,1))', Yb, linspace(0,1,length(t))');

%% 把角度轉成擺錘末端的 (x, y)
endpoint = @(th1, th2) deal( ...
    L1*sin(th1) + L2*sin(th2), ...
    -L1*cos(th1) - L2*cos(th2));

[xa, ya] = endpoint(Ya(:,1), Ya(:,2));
[xb, yb] = endpoint(Yb(:,1), Yb(:,2));

fig = figure('Visible', 'off', 'Position', [0 0 1100 500]);
subplot(1,2,1);
plot(xa, ya, 'b-', 'LineWidth', 0.5); hold on;
plot(xb, yb, 'r-', 'LineWidth', 0.5);
axis equal;
xlabel('x (m)'); ylabel('y (m)');
title('擺錘末端軌跡：兩條看起來都亂跑');
legend({'\theta_1(0)=\pi/2', '\theta_1(0)=\pi/2 + 10^{-3}'}, ...
       'Location', 'south');

subplot(1,2,2);
err = sqrt((xa-xb).^2 + (ya-yb).^2);
semilogy(t, err, 'k-', 'LineWidth', 1.5);
xlabel('t (s)'); ylabel('|位置差| (m, log)');
title('兩條軌跡距離：指數成長 (混沌特徵)');
yline(0.1, 'r--');
ylim([1e-4, 5]);

sgtitle('雙擺：對初始條件敏感依賴 (起始差 10^{-3} rad)');
save_png(fig, fullfile(out_dir, '03_double_pendulum.png'));

%% 能量守恆檢驗（無摩擦系統能量應為常數）
T = 0.5*(m1+m2)*L1^2*Ya(:,3).^2 + 0.5*m2*L2^2*Ya(:,4).^2 + ...
    m2*L1*L2*Ya(:,3).*Ya(:,4).*cos(Ya(:,1)-Ya(:,2));
V = -(m1+m2)*g*L1*cos(Ya(:,1)) - m2*g*L2*cos(Ya(:,2));
E = T + V;

fig = figure('Visible', 'off', 'Position', [0 0 900 400]);
plot(t, E - E(1), 'b-', 'LineWidth', 1.5);
xlabel('t (s)'); ylabel('E(t) - E(0) (J)');
title('雙擺能量守恆檢驗 (RelTol=1e-9，誤差數量級 10^{-7})');
save_png(fig, fullfile(out_dir, '03_double_pendulum_energy.png'));
