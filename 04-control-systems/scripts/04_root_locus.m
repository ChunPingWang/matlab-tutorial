%% 章節 04-4：根軌跡 (Root Locus)
% 看回授增益 K 變化時極點怎麼跑
% 控制設計直覺最強的工具之一
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% 系統：3 階 plant
G = tf(1, conv([1, 1], conv([1, 2], [1, 5])));
% G(s) = 1 / [(s+1)(s+2)(s+5)]

%% 根軌跡
fig = figure('Visible', 'off', 'Position', [0 0 800 700]);
rlocus(G);
grid on;
title('根軌跡：K 變化時閉迴路極點的軌跡');
sgrid(0.7, []);   % 畫出 zeta=0.7 的等阻尼線
save_png(fig, fullfile(out_dir, '04_rlocus.png'));

%% 用 rlocfind 風格手動找 K：例如要極點在 zeta=0.5 上
% 解 1 + K*G(s) = 0，逐步嘗試 K
Ks = [0.5, 5, 20, 50, 100];
fig = figure('Visible', 'off', 'Position', [0 0 900 700]);
rlocus(G); hold on;
sgrid(0.5, []);
colors = lines(length(Ks));
for i = 1:length(Ks)
    K = Ks(i);
    poles = rlocus(G, K);
    plot(real(poles), imag(poles), 'o', 'MarkerSize', 12, ...
         'LineWidth', 2.5, 'Color', colors(i,:), ...
         'DisplayName', sprintf('K = %g', K));
end
legend('Location', 'southwest');
title('幾個關鍵 K 值的閉迴路極點位置');
xlim([-6, 2]);
save_png(fig, fullfile(out_dir, '04_rlocus_marks.png'));

%% 增益 K 對閉迴路步階響應的影響
fig = figure('Visible', 'off', 'Position', [0 0 1000 500]);
for i = 1:length(Ks)
    K = Ks(i);
    T = feedback(K*G, 1);
    [y, t] = step(T, 8);
    plot(t, y, 'LineWidth', 2, ...
         'DisplayName', sprintf('K = %g', K), 'Color', colors(i,:)); hold on;
end
yline(1, 'k:');
xlabel('t (s)'); ylabel('y(t)');
title('K 越大反應越快，但過大會不穩定 (K=100 振盪到發散邊緣)');
legend('Location', 'northeast');
ylim([0, 2.2]);
save_png(fig, fullfile(out_dir, '04_rlocus_step.png'));

%% 找臨界穩定 K (根軌跡碰到 jw 軸的點)
% 用 routh 或直接掃描
Ks_scan = logspace(0, 3, 200);
max_real = zeros(size(Ks_scan));
for i = 1:length(Ks_scan)
    poles = rlocus(G, Ks_scan(i));
    max_real(i) = max(real(poles));
end

fig = figure('Visible', 'off', 'Position', [0 0 900 500]);
semilogx(Ks_scan, max_real, 'b-', 'LineWidth', 2);
yline(0, 'r--', '穩定邊界');
% 找穿越點
idx = find(max_real > 0, 1, 'first');
K_crit = Ks_scan(idx);
xline(K_crit, 'k:', sprintf('臨界 K \\approx %.0f', K_crit));
xlabel('K (log)'); ylabel('max Re(極點)');
title('閉迴路最不穩定極點的實部 vs K');
save_png(fig, fullfile(out_dir, '04_rlocus_critical.png'));
fprintf('臨界穩定 K ≈ %.1f\n', K_crit);
