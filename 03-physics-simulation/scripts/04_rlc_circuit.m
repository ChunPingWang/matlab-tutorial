%% 章節 03-4：RLC 電路
% 用 Kirchhoff 電壓定律導出 ODE，看「電路就是電的彈簧質量阻尼」
% L*Q'' + R*Q' + (1/C)*Q = V(t)
% Q 是電容上的電荷，i = Q' 是電流
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% 電路參數
L = 0.1;    % Henry  (電感「等效質量」)
R = 5;      % Ohm    (電阻「等效阻尼」)
C = 1e-4;   % Farad  (電容「等效彈簧倒數」1/k)

omega_n = 1/sqrt(L*C);
zeta = R/(2*sqrt(L/C));
fprintf('omega_n = %.0f rad/s (%.0f Hz), zeta = %.3f\n', ...
        omega_n, omega_n/(2*pi), zeta);

%% 1. 階躍輸入：t>=0 加 12V
V_step = @(t) 12 * (t >= 0);
% 狀態 y = [Q; Q'] = [Q; i]
rhs_step = @(t, y) [y(2);
                    (-R*y(2) - y(1)/C + V_step(t)) / L];

tspan = [0, 0.02];
[t, Y] = ode45(rhs_step, tspan, [0; 0]);
Vc = Y(:,1)/C;   % 電容電壓 = Q/C
i  = Y(:,2);

fig = figure('Visible', 'off', 'Position', [0 0 1000 500]);
subplot(2,1,1);
plot(t*1000, Vc, 'b-', 'LineWidth', 2); hold on;
yline(12, 'r--', '輸入電壓 12V');
xlabel('t (ms)'); ylabel('V_C (V)');
title('RLC 階躍響應：電容電壓 V_C');

subplot(2,1,2);
plot(t*1000, i, 'r-', 'LineWidth', 2);
xlabel('t (ms)'); ylabel('i (A)');
title('電流（與位移-彈簧系統的「速度」對應）');

sgtitle(sprintf('RLC 階躍：L=%gH, R=%gOhm, C=%gF, \\zeta=%.2f', L, R, C, zeta));
save_png(fig, fullfile(out_dir, '04_rlc_step.png'));

%% 2. 弦波輸入：掃頻看頻率響應
freqs = logspace(1, 4, 60);         % 10 Hz ~ 10kHz
gain = zeros(size(freqs));
phase = zeros(size(freqs));

for k = 1:length(freqs)
    f = freqs(k);
    w = 2*pi*f;
    V_in = @(t) sin(w*t);
    rhs = @(t, y) [y(2); (-R*y(2) - y(1)/C + V_in(t))/L];
    [t, Y] = ode45(rhs, [0, 5/f], [0; 0]);
    Vc = Y(:,1)/C;
    % 取穩態最後一週期分析
    idx = t > 4/f;
    gain(k) = (max(Vc(idx)) - min(Vc(idx))) / 2;
end

fig = figure('Visible', 'off', 'Position', [0 0 900 500]);
semilogx(freqs, 20*log10(gain + 1e-9), 'b-', 'LineWidth', 2);
xline(omega_n/(2*pi), 'r--', sprintf('共振 %.0f Hz', omega_n/(2*pi)));
xlabel('頻率 (Hz)'); ylabel('|V_C/V_{in}| (dB)');
title('RLC 帶通：共振於 \omega_n');
grid on;
save_png(fig, fullfile(out_dir, '04_rlc_freq.png'));

%% 3. 用 Control System Toolbox 對照
% V_C(s)/V_in(s) = 1 / (LC*s^2 + RC*s + 1)
sys = tf(1, [L*C, R*C, 1]);
fig = figure('Visible', 'off', 'Position', [0 0 900 600]);
bode(sys, {1, 1e5});
title('用 tf + bode 一行畫出（後章節會大量用）');
save_png(fig, fullfile(out_dir, '04_rlc_bode.png'));
