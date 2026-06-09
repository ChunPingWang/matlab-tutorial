%% 章節 04-1：傳遞函數 (Transfer Function) 入門
% 把 ODE 模型轉成 G(s) = Y(s)/U(s)
% 以 DC 馬達為例
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% DC 馬達物理模型
% 電氣：L*di/dt + R*i + Kb*omega = V
% 機械：J*omega' + B*omega = Kt*i
% 假設 L 很小可忽略 (常見近似)：i = (V - Kb*omega) / R
% 代入機械式：J*omega' = -B*omega + Kt*(V - Kb*omega)/R
%             = -(B + Kt*Kb/R)*omega + (Kt/R)*V

% 參數
J = 0.01;       % 慣量 kg.m^2
B = 0.1;        % 摩擦 N.m.s
Kt = 0.01;      % 轉矩常數
Kb = 0.01;      % 反電動勢常數
R = 1;          % Ohm

% 傳遞函數 G(s) = omega(s)/V(s) = (Kt/R) / (J*s + B + Kt*Kb/R)
num = Kt/R;
den = [J, B + Kt*Kb/R];
G = tf(num, den);
disp('DC 馬達傳遞函數 G(s) = omega/V：');
G

%% 直接從 ODE 模擬 vs 從傳遞函數模擬：應該一致
% 階躍響應：V=1V，看 omega(t)
fig = figure('Visible', 'off', 'Position', [0 0 900 500]);

% (a) 從 ODE 解
ode_motor = @(t, w) -(B + Kt*Kb/R)/J * w + Kt/(R*J) * 1.0;
[t_ode, w_ode] = ode45(ode_motor, [0, 5], 0);

% (b) 從 tf 用 step
[w_tf, t_tf] = step(G, 5);

plot(t_ode, w_ode, 'b-', 'LineWidth', 3); hold on;
plot(t_tf, w_tf, 'r--', 'LineWidth', 2);
xlabel('t (s)'); ylabel('\omega (rad/s)');
title('DC 馬達階躍響應：ODE 解 vs tf-step 完全一致');
legend({'ode45 數值解', 'tf + step'}, 'Location', 'southeast');
save_png(fig, fullfile(out_dir, '01_motor_step.png'));

%% 比較不同階次系統的階躍響應
fig = figure('Visible', 'off', 'Position', [0 0 1000 500]);
G1 = tf(1, [1, 1]);                    % 1 階
G2 = tf(1, [1, 0.5, 1]);               % 2 階欠阻尼
G3 = tf(1, conv([1, 1], [1, 0.5, 1])); % 3 階

[y1, t] = step(G1, 20);
y2 = step(G2, t);
y3 = step(G3, t);

plot(t, y1, 'b-', t, y2, 'r--', t, y3, 'k-.', 'LineWidth', 2);
yline(1, 'k:', '穩態');
xlabel('t (s)'); ylabel('y(t)');
title('一階 / 二階 / 三階系統的階躍響應');
legend({'1/(s+1)', '1/(s^2+0.5s+1)', '加一階至 3 階'}, 'Location', 'southeast');
save_png(fig, fullfile(out_dir, '01_order_compare.png'));

%% 零極點圖：系統穩定性「一眼看出」
fig = figure('Visible', 'off', 'Position', [0 0 1000 500]);
subplot(1,2,1);
G_stable = tf([1, 2], [1, 0.5, 4]);   % 極點 -0.25 ± 1.98i (穩定)
pzmap(G_stable);
title('穩定系統：極點都在左半平面');

subplot(1,2,2);
G_unstable = tf(1, [1, -0.5, 4]);     % 極點 0.25 ± 1.98i (不穩定)
pzmap(G_unstable);
title('不穩定系統：極點跑到右半平面');

save_png(fig, fullfile(out_dir, '01_pzmap.png'));
