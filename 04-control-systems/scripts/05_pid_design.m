%% 章節 04-5：PID 控制器設計
% 用 DC 馬達速度控制做例子，比較 P / PI / PID 效果
% 並示範用 pidtune 自動調參
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% DC 馬達 plant (第 01 節推導)
J = 0.01; B = 0.1; Kt = 0.01; Kb = 0.01; R = 1;
G = tf(Kt/R, [J, B + Kt*Kb/R]);

%% 比較 P / PI / PID
% 目標：階躍 1 rad/s，要求無穩態誤差、過衝 < 10%、settling < 1s
fig = figure('Visible', 'off', 'Position', [0 0 1000 600]);

% (1) 無控制 (open-loop)，1V 階躍
[y_ol, t] = step(G, 4);
plot(t, y_ol, 'k-', 'LineWidth', 2, 'DisplayName', '無控制 (1V 階躍)'); hold on;

% (2) 純 P 控制 (Kp=10)
Kp = 10;
C = pid(Kp);
T = feedback(C*G, 1);
[y, ~] = step(T, t);
plot(t, y, 'b-', 'LineWidth', 2, 'DisplayName', sprintf('P 控制 K_p=%d (有穩態誤差)', Kp));

% (3) PI 控制
C = pid(Kp, 5);
T = feedback(C*G, 1);
[y, ~] = step(T, t);
plot(t, y, 'r-', 'LineWidth', 2, 'DisplayName', 'PI: K_p=10, K_i=5 (誤差消失但慢)');

% (4) PID 控制（手調）
C = pid(100, 200, 1);
T = feedback(C*G, 1);
[y, ~] = step(T, t);
plot(t, y, 'g-', 'LineWidth', 2, 'DisplayName', 'PID: 100/200/1 (快但過衝)');

yline(1, 'k:', '目標');
xlabel('t (s)'); ylabel('\omega (rad/s)');
title('DC 馬達速度控制：P / PI / PID 比較');
legend('Location', 'southeast');
ylim([0, 1.3]);
save_png(fig, fullfile(out_dir, '05_pid_compare.png'));

%% pidtune 自動調參
[C_auto, info] = pidtune(G, 'PID');
fprintf('pidtune 自動 PID：Kp=%.2f, Ki=%.2f, Kd=%.4f\n', ...
        C_auto.Kp, C_auto.Ki, C_auto.Kd);
fprintf('Bode 頻寬：%.2f rad/s，相位餘裕：%.1f deg\n', ...
        info.CrossoverFrequency, info.PhaseMargin);

fig = figure('Visible', 'off', 'Position', [0 0 1000 500]);
T_auto = feedback(C_auto*G, 1);
[y, t] = step(T_auto, 5);
plot(t, y, 'b-', 'LineWidth', 2.5); hold on;
yline(1, 'k:', '目標 1 rad/s');

info_t = stepinfo(T_auto);
yline(info_t.Peak, 'r--', sprintf('Peak %.3f (%.1f%% 過衝)', info_t.Peak, info_t.Overshoot));
xline(info_t.SettlingTime, 'm--', sprintf('Settling %.2f s', info_t.SettlingTime));
xlabel('t (s)'); ylabel('\omega (rad/s)');
title(sprintf('pidtune 結果：K_p=%.1f, K_i=%.1f, K_d=%.3f', ...
              C_auto.Kp, C_auto.Ki, C_auto.Kd));
save_png(fig, fullfile(out_dir, '05_pid_auto.png'));

%% Ziegler-Nichols 經驗法則對照
% 步驟：純 P 增益 Kp，加大到剛好持續振盪，得到 Ku 和 Tu
% 然後 ZN-PID:  Kp = 0.6*Ku, Ki = Kp/(0.5*Tu), Kd = Kp*Tu/8
% 對純一階+延遲系統有效，對 DC 馬達實作這裡僅示意

% 我們用根軌跡找出純 P 的臨界 K
% 對 G(s) = 0.01 / (0.01 s + 0.1001) 是嚴格穩定的一階系統
% (J*s + B+Kt*Kb/R = 0.01s + 0.1001)
% 所以單純 P 永遠不會振盪，這也是純 P 不夠的另一個原因。
% 對更複雜的 plant，看 04 節示範。

%% 干擾抑制：在輸入加干擾，看閉迴路怎麼修正
% 假設 t=2s 時加一個負載干擾 d(t) = 0.5
fig = figure('Visible', 'off', 'Position', [0 0 1000 500]);
t = linspace(0, 5, 1000);
r = ones(size(t));               % 目標 1 rad/s
d = 0.5 * (t >= 2);              % t=2s 時 0.5N.m 負載

% 對 r -> y：用閉迴路 T
% 對 d -> y：需要構造 d 進入 plant 之前的點
% 簡化：把 d 視為對 control input 的擾動：u_actual = u + d
% 模擬整個迴路用 lsim
[y_r, ~] = step(T_auto, t);
% 對干擾：先把 control 從 plant input 加 d，所以 d 對應 G/(1+CG)
T_dy = feedback(G, C_auto);
y_d = lsim(T_dy, d, t);
y_total = y_r + y_d;

plot(t, r, 'k:', 'LineWidth', 1.5); hold on;
plot(t, y_total, 'b-', 'LineWidth', 2.5);
plot(t, 0.5*(t>=2), 'r--', 'LineWidth', 1.5);
xlabel('t (s)'); ylabel('value');
legend({'參考 r=1', '輸出 \omega(t)', '干擾 d(t)'}, 'Location', 'east');
title('PID 對負載干擾的抑制 (t=2s 加負載)');
save_png(fig, fullfile(out_dir, '05_pid_disturbance.png'));
