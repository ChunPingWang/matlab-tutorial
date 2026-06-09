%% 章節 03-1：含空氣阻力的拋體運動
% 比較「真空」與「有空氣阻力」軌跡
% 用 ode45 解 4 個狀態 [x; y; vx; vy] 的一階系統
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% 物理參數
g = 9.81;       % m/s^2
m = 0.145;      % kg (棒球質量)
rho = 1.225;    % kg/m^3 (空氣密度)
Cd = 0.47;      % 球體拖曳係數
r_ball = 0.0366; % m (棒球半徑)
A = pi * r_ball^2;
b = 0.5 * rho * Cd * A / m;  % 阻力係數除以質量

%% 初始條件：以 45 度角發射，速度 50 m/s
v0 = 50;
angle_deg = 45;
vx0 = v0 * cosd(angle_deg);
vy0 = v0 * sind(angle_deg);
s0 = [0; 0; vx0; vy0];

%% 1. 真空中（無阻力）
dyn_vac = @(t, s) [s(3); s(4); 0; -g];
opts = odeset('Events', @hitGround3);
[t_v, S_v] = ode45(dyn_vac, [0, 20], s0, opts);

%% 2. 含空氣阻力：F_drag = -b * |v| * v
dyn_air = @(t, s) [s(3);
                   s(4);
                   -b * sqrt(s(3)^2 + s(4)^2) * s(3);
                   -g - b * sqrt(s(3)^2 + s(4)^2) * s(4)];
[t_a, S_a] = ode45(dyn_air, [0, 20], s0, opts);

fprintf('真空射程：%.1f m, 飛行 %.2f s\n', S_v(end, 1), t_v(end));
fprintf('空阻射程：%.1f m, 飛行 %.2f s\n', S_a(end, 1), t_a(end));

%% 畫軌跡比較
fig = figure('Visible', 'off', 'Position', [0 0 900 500]);
plot(S_v(:,1), S_v(:,2), 'b-', 'LineWidth', 2); hold on;
plot(S_a(:,1), S_a(:,2), 'r--', 'LineWidth', 2);
yline(0, 'k-');
xlabel('x (m)'); ylabel('y (m)');
title('拋體軌跡：真空 vs 含空氣阻力 (棒球，v_0=50 m/s, 45 度)');
legend({sprintf('真空 (%.1f m)', S_v(end,1)), ...
        sprintf('含阻力 (%.1f m)', S_a(end,1))}, 'Location', 'south');
axis equal;
save_png(fig, fullfile(out_dir, '01_projectile_traj.png'));

%% 不同發射角的最佳角度
angles = 30:1:60;
ranges_vac = zeros(size(angles));
ranges_air = zeros(size(angles));
for k = 1:length(angles)
    a = angles(k);
    s0 = [0; 0; v0*cosd(a); v0*sind(a)];
    [~, Sv] = ode45(dyn_vac, [0, 20], s0, opts);
    [~, Sa] = ode45(dyn_air, [0, 20], s0, opts);
    ranges_vac(k) = Sv(end, 1);
    ranges_air(k) = Sa(end, 1);
end

fig = figure('Visible', 'off', 'Position', [0 0 900 500]);
plot(angles, ranges_vac, 'b-o', 'LineWidth', 2); hold on;
plot(angles, ranges_air, 'r--s', 'LineWidth', 2);
[~, idx_v] = max(ranges_vac);
[~, idx_a] = max(ranges_air);
xline(angles(idx_v), 'b:', sprintf('真空最佳 %d°', angles(idx_v)));
xline(angles(idx_a), 'r:', sprintf('含阻最佳 %d°', angles(idx_a)));
xlabel('發射角 (度)'); ylabel('射程 (m)');
title('最佳發射角：真空理論 45 度，含阻力 < 45 度');
legend({'真空', '含空氣阻力'}, 'Location', 'south');
save_png(fig, fullfile(out_dir, '01_projectile_optimal_angle.png'));
