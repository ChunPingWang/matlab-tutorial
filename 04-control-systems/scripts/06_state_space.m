%% 章節 04-6：狀態空間 (State-Space) 表示與 MIMO
% 多輸入多輸出系統的標準型式
% 例：兩階「彈簧質量阻尼」改寫成狀態空間
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% 彈簧質量阻尼：m*x'' + c*x' + k*x = u
m = 1; c = 0.5; k = 4;

% 狀態 z = [x; x']
% z' = A*z + B*u
% y  = C*z + D*u
A = [0,       1;
     -k/m,  -c/m];
B = [0;  1/m];
C = [1, 0];        % 量測位移
D = 0;

sys = ss(A, B, C, D);

%% 從 ss 轉 tf 確認
sys_tf = tf(sys);
disp('從 state-space 轉成傳遞函數：');
sys_tf

%% 階躍響應
fig = figure('Visible', 'off', 'Position', [0 0 900 500]);
[y, t] = step(sys, 15);
plot(t, y, 'LineWidth', 2);
xlabel('t (s)'); ylabel('位移 x');
title('彈簧質量阻尼系統的階躍響應（從 state-space 模型）');
grid on;
save_png(fig, fullfile(out_dir, '06_ss_step.png'));

%% 可控性 / 可觀測性
Co = ctrb(A, B);   % 可控矩陣
Ob = obsv(A, C);   % 可觀測矩陣
fprintf('可控矩陣 rank = %d / %d (滿秩=可控)\n', rank(Co), size(A,1));
fprintf('可觀測矩陣 rank = %d / %d (滿秩=可觀測)\n', rank(Ob), size(A,1));

%% 極點配置 (place)：把閉迴路極點放到指定位置
% 目標：把極點放在 -2 ± 1j（更快、阻尼較大）
desired_poles = [-2 + 1i, -2 - 1i];
K = place(A, B, desired_poles);
fprintf('狀態回授增益 K = [%.3f, %.3f]\n', K);

% 閉迴路：A_cl = A - B*K
A_cl = A - B*K;
sys_cl = ss(A_cl, B, C, D);

fig = figure('Visible', 'off', 'Position', [0 0 1000 500]);
subplot(1,2,1);
pzmap(sys, sys_cl);
title('極點配置：開迴路 vs 閉迴路');
legend({'open-loop', 'closed-loop (-2 \pm j)'}, 'Location', 'northwest');

subplot(1,2,2);
[y, t] = step(sys, 8); plot(t, y, 'b-', 'LineWidth', 2); hold on;
[y, t] = step(sys_cl, 8); plot(t, y, 'r-', 'LineWidth', 2);
% 步階輸入下 closed-loop 的 DC gain 改變，要 normalize
y_cl_norm = y / dcgain(sys_cl);
plot(t, y_cl_norm, 'r--', 'LineWidth', 2);
xlabel('t (s)'); ylabel('y');
legend({'open-loop', 'closed-loop (raw)', 'closed-loop (normalized)'}, ...
       'Location', 'southeast');
title('閉迴路反應比開迴路快很多');
save_png(fig, fullfile(out_dir, '06_place.png'));

%% MIMO 例：耦合系統
% 兩個質量用一根彈簧連接
% m1*x1'' = -k*(x1-x2) - c*x1' + u1
% m2*x2'' = -k*(x2-x1) - c*x2' + u2
m1=1; m2=1; k=2; c=0.1;
A_mimo = [0  0  1  0;
          0  0  0  1;
         -k  k -c  0;
          k -k  0 -c] ./ [1 1 1 1; 1 1 1 1; m1 m1 m1 m1; m2 m2 m2 m2];
B_mimo = [0 0;
          0 0;
          1/m1 0;
          0 1/m2];
C_mimo = [1 0 0 0;
          0 1 0 0];    % 兩個輸出：x1, x2
D_mimo = zeros(2, 2);

sys_mimo = ss(A_mimo, B_mimo, C_mimo, D_mimo);
sys_mimo.InputName = {'u1', 'u2'};
sys_mimo.OutputName = {'x1', 'x2'};

fig = figure('Visible', 'off', 'Position', [0 0 900 700]);
step(sys_mimo, 20);
title('MIMO 階躍：兩個輸入分別對兩個輸出');
save_png(fig, fullfile(out_dir, '06_mimo.png'));
