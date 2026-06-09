%% 章節 04-2：階躍響應的時域規格
% 上升時間、過衝、settling time、穩態誤差
% 用 stepinfo 直接拿到所有時域指標
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% 典型二階系統的階躍響應
% G(s) = wn^2 / (s^2 + 2*zeta*wn*s + wn^2)
wn = 2;
zetas = [0.1, 0.3, 0.7, 1.0];

fig = figure('Visible', 'off', 'Position', [0 0 1000 600]);
for k = 1:length(zetas)
    z = zetas(k);
    G = tf(wn^2, [1, 2*z*wn, wn^2]);
    [y, t] = step(G, 10);
    plot(t, y, 'LineWidth', 2, ...
         'DisplayName', sprintf('\\zeta = %.1f', z)); hold on;
end
yline(1, 'k:', '穩態 = 1');
yline(1.05, 'k--', '5% 範圍');
yline(0.95, 'k--');
xlabel('t (s)'); ylabel('y(t)');
title(sprintf('二階系統階躍響應 (\\omega_n = %d)', wn));
legend('Location', 'southeast');
save_png(fig, fullfile(out_dir, '02_step_zetas.png'));

%% stepinfo：自動算規格
fprintf('時域規格分析（zeta = 0.3）：\n');
G = tf(wn^2, [1, 2*0.3*wn, wn^2]);
info = stepinfo(G);
disp(info);
fprintf('上升時間 RiseTime = %.3f s\n', info.RiseTime);
fprintf('settling time = %.3f s\n', info.SettlingTime);
fprintf('峰值時間 PeakTime = %.3f s\n', info.PeakTime);
fprintf('過衝 Overshoot = %.2f %%\n', info.Overshoot);
fprintf('峰值 Peak = %.3f\n', info.Peak);

%% 視覺化規格在圖上
fig = figure('Visible', 'off', 'Position', [0 0 1000 600]);
[y, t] = step(G, 10);
plot(t, y, 'b-', 'LineWidth', 2.5); hold on;
yline(1, 'k:');
yline(info.Peak, 'r--', sprintf('Peak = %.2f', info.Peak));
xline(info.PeakTime, 'r:', sprintf('PeakTime = %.2fs', info.PeakTime));
xline(info.RiseTime, 'g:', sprintf('RiseTime = %.2fs', info.RiseTime));
xline(info.SettlingTime, 'm:', sprintf('Settling = %.2fs', info.SettlingTime));

% 過衝高亮
text(info.PeakTime+0.1, info.Peak+0.02, ...
     sprintf('Overshoot = %.1f%%', info.Overshoot), ...
     'FontSize', 11, 'Color', 'r');

xlabel('t (s)'); ylabel('y(t)');
title(sprintf('時域規格視覺化（\\zeta = 0.3, \\omega_n = %d）', wn));
ylim([0, 1.6]);
save_png(fig, fullfile(out_dir, '02_step_specs.png'));

%% omega_n 的影響：定 zeta = 0.7，看不同 omega_n 對 settling time
fig = figure('Visible', 'off', 'Position', [0 0 1000 500]);
wns = [1, 2, 4, 8];
for k = 1:length(wns)
    wn = wns(k);
    G = tf(wn^2, [1, 2*0.7*wn, wn^2]);
    [y, t] = step(G, 5);
    plot(t, y, 'LineWidth', 2, ...
         'DisplayName', sprintf('\\omega_n = %d', wn)); hold on;
end
yline(1, 'k:');
xlabel('t (s)'); ylabel('y(t)');
title(sprintf('固定 \\zeta = 0.7，\\omega_n 越大反應越快'));
legend('Location', 'southeast');
save_png(fig, fullfile(out_dir, '02_step_wn.png'));
