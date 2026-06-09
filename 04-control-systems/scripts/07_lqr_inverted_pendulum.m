%% 章節 04-7：LQR 控制 - 倒立擺
% Linear Quadratic Regulator
% 目標：把車上的倒立擺 (在原本不穩定的「上方平衡點」) 穩住
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% 物理參數
M = 0.5;    % 車質量 kg
m = 0.2;    % 擺質量 kg
b = 0.1;    % 摩擦
I = 0.006;  % 擺繞質心轉動慣量
g = 9.81;
l = 0.3;    % 擺長一半

p = I*(M+m) + M*m*l^2;
% 在 theta=0 (向上) 線性化後的狀態空間
% 狀態：[x; x'; theta; theta']
A = [0       1        0        0;
     0   -(I+m*l^2)*b/p   (m^2*g*l^2)/p   0;
     0       0        0        1;
     0   -(m*l*b)/p   m*g*l*(M+m)/p   0];
B = [0;
     (I+m*l^2)/p;
     0;
     m*l/p];
C = [1 0 0 0;
     0 0 1 0];
D = [0; 0];

sys_open = ss(A, B, C, D);
fprintf('開迴路極點：\n');
disp(eig(A));
fprintf('（出現正實部 -> 開迴路不穩定，物理上倒立擺的確會倒）\n');

%% LQR 設計
% 代價函數 J = ∫ (x'Qx + u'Ru) dt
% Q 大：罰狀態偏離；R 大：罰控制能量
Q = diag([10, 1, 100, 1]);   % 強調 theta 不能偏 (倒立才是重點)
R = 0.1;

K = lqr(A, B, Q, R);
fprintf('LQR 增益 K = [%.2f, %.2f, %.2f, %.2f]\n', K);

%% 模擬閉迴路
A_cl = A - B*K;
% 我們希望把擺收到 theta=0、車到 x=0
% 初始狀態：擺偏 0.1 rad (約 5.7 度)，車在原點
x0 = [0; 0; 0.1; 0];

% 動態：z' = (A-BK)*z
ode_cl = @(t, z) A_cl * z;
[t, Z] = ode45(ode_cl, [0, 5], x0);

fig = figure('Visible', 'off', 'Position', [0 0 1000 600]);
subplot(2,1,1);
plot(t, Z(:,3)*180/pi, 'r-', 'LineWidth', 2);
yline(0, 'k:');
xlabel('t (s)'); ylabel('\theta (deg)');
title('擺角從 5.7° 收斂到 0 (倒立穩住)');

subplot(2,1,2);
plot(t, Z(:,1), 'b-', 'LineWidth', 2);
yline(0, 'k:');
xlabel('t (s)'); ylabel('x (m)');
title('車位置：先往前再修正回原點');

sgtitle(sprintf('LQR 倒立擺穩定 (Q=diag(10,1,100,1), R=%.1f)', R));
save_png(fig, fullfile(out_dir, '07_lqr_response.png'));

%% 計算控制力
u = -K * Z';
fig = figure('Visible', 'off', 'Position', [0 0 900 400]);
plot(t, u, 'k-', 'LineWidth', 2);
xlabel('t (s)'); ylabel('u (N)');
title('LQR 求得的控制力 u(t) = -K*x');
grid on;
save_png(fig, fullfile(out_dir, '07_lqr_control_effort.png'));

%% Q 與 R 的權衡：改 R 看控制力 vs 收斂速度
fig = figure('Visible', 'off', 'Position', [0 0 1100 600]);
Rs = [0.01, 0.1, 1, 10];
colors = lines(length(Rs));

for k = 1:length(Rs)
    Ri = Rs(k);
    Ki = lqr(A, B, Q, Ri);
    Ai = A - B*Ki;
    [t, Z] = ode45(@(t,z) Ai*z, [0, 5], x0);

    subplot(2,1,1);
    plot(t, Z(:,3)*180/pi, 'LineWidth', 2, ...
         'Color', colors(k,:), ...
         'DisplayName', sprintf('R = %g', Ri)); hold on;

    subplot(2,1,2);
    plot(t, -Ki*Z', 'LineWidth', 2, ...
         'Color', colors(k,:), ...
         'DisplayName', sprintf('R = %g', Ri)); hold on;
end
subplot(2,1,1);
xlabel('t (s)'); ylabel('\theta (deg)');
title('R 小 -> 收斂快');
legend('Location', 'northeast');
yline(0, 'k:');

subplot(2,1,2);
xlabel('t (s)'); ylabel('u (N)');
title('R 小 -> 但需要的控制力大');
legend('Location', 'northeast');

sgtitle('LQR 設計權衡：R 控制「能量限制」');
save_png(fig, fullfile(out_dir, '07_lqr_R_tradeoff.png'));
