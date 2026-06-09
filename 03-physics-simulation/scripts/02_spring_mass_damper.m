%% 章節 03-2：彈簧-質量-阻尼系統
% m*x'' + c*x' + k*x = F(t)
% 比較三種阻尼程度：欠阻尼、臨界阻尼、過阻尼
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% 物理參數
m = 1;          % kg
k = 4;          % N/m (自然頻率 omega_n = sqrt(k/m) = 2 rad/s)
omega_n = sqrt(k/m);

% 阻尼比 zeta = c / (2*sqrt(m*k))
% 臨界阻尼時 c = 2*sqrt(m*k) = 4
% zeta < 1: 欠阻尼 (oscillation)
% zeta = 1: 臨界阻尼 (最快收斂無振盪)
% zeta > 1: 過阻尼 (慢慢爬回)

cases = struct( ...
    'zeta', {0.1, 0.5, 1.0, 2.0}, ...
    'name', {'欠阻尼 \zeta=0.1', '欠阻尼 \zeta=0.5', '臨界阻尼 \zeta=1.0', '過阻尼 \zeta=2.0'}, ...
    'color', {'b', 'g', 'k', 'r'}, ...
    'style', {'-', '-', '-', '--'});

%% 自由響應：給初始位移後放開
fig = figure('Visible', 'off', 'Position', [0 0 1000 500]);
for i = 1:length(cases)
    zeta = cases(i).zeta;
    c = 2 * zeta * sqrt(m*k);
    f = @(t, y) [y(2); -(c/m)*y(2) - (k/m)*y(1)];
    [t, Y] = ode45(f, [0, 10], [1; 0]);
    plot(t, Y(:,1), [cases(i).color cases(i).style], 'LineWidth', 2, ...
         'DisplayName', cases(i).name); hold on;
end
xlabel('t (s)'); ylabel('位移 x(t)');
title('彈簧-質量-阻尼自由響應，x(0)=1, x''(0)=0');
legend('Location', 'northeast');
yline(0, 'k:');
save_png(fig, fullfile(out_dir, '02_spring_free.png'));

%% 受迫振盪：F(t) = F0 * sin(omega*t)，掃 omega 看共振
F0 = 1;
omegas = linspace(0.5, 4, 40);
amplitudes = zeros(length(omegas), 3);
zetas = [0.1, 0.3, 0.7];

for j = 1:length(zetas)
    zeta = zetas(j);
    c = 2 * zeta * sqrt(m*k);
    for i = 1:length(omegas)
        w = omegas(i);
        F = @(t) F0 * sin(w*t);
        f = @(t, y) [y(2); -(c/m)*y(2) - (k/m)*y(1) + F(t)/m];
        [t, Y] = ode45(f, [0, 50], [0; 0]);
        % 取穩態振幅（最後 25% 的最大值）
        idx_steady = t > 0.75 * t(end);
        amplitudes(i, j) = max(Y(idx_steady, 1));
    end
end

fig = figure('Visible', 'off', 'Position', [0 0 900 500]);
for j = 1:length(zetas)
    plot(omegas/omega_n, amplitudes(:,j), 'LineWidth', 2, ...
         'DisplayName', sprintf('\\zeta = %.1f', zetas(j))); hold on;
end
xline(1, 'k--', '\omega/\omega_n = 1 (共振)');
xlabel('\omega / \omega_n'); ylabel('穩態振幅');
title('受迫振盪共振曲線：阻尼越小峰越尖');
legend('Location', 'northeast');
save_png(fig, fullfile(out_dir, '02_spring_resonance.png'));

%% 相平面：欠阻尼 vs 過阻尼
fig = figure('Visible', 'off', 'Position', [0 0 1000 500]);
subplot(1,2,1);
zeta = 0.1;  c = 2*zeta*sqrt(m*k);
f = @(t, y) [y(2); -(c/m)*y(2) - (k/m)*y(1)];
% 多條軌跡
for x0 = -2:0.5:2
    for v0 = -2:0.5:2
        if abs(x0)+abs(v0) > 0
            [~, Y] = ode45(f, [0, 30], [x0; v0]);
            plot(Y(:,1), Y(:,2), 'b-', 'LineWidth', 0.5); hold on;
        end
    end
end
xlabel('x'); ylabel('x'''); xlim([-2.5, 2.5]); ylim([-2.5, 2.5]);
title(sprintf('欠阻尼 \\zeta=0.1：螺旋收斂'));

subplot(1,2,2);
zeta = 2.0;  c = 2*zeta*sqrt(m*k);
f = @(t, y) [y(2); -(c/m)*y(2) - (k/m)*y(1)];
for x0 = -2:0.5:2
    for v0 = -2:0.5:2
        if abs(x0)+abs(v0) > 0
            [~, Y] = ode45(f, [0, 30], [x0; v0]);
            plot(Y(:,1), Y(:,2), 'r-', 'LineWidth', 0.5); hold on;
        end
    end
end
xlabel('x'); ylabel('x'''); xlim([-2.5, 2.5]); ylim([-2.5, 2.5]);
title(sprintf('過阻尼 \\zeta=2.0：直接爬回'));

sgtitle('相平面流場');
save_png(fig, fullfile(out_dir, '02_spring_phase.png'));
