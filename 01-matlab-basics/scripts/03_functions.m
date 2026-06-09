%% 章節 01-3：函式三種寫法
% script 本地函式、外部 .m 函式、匿名函式（function handle）
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% 1. 匿名函式（anonymous function / function handle）
% 一行一個小函式，最常用
f = @(x) x.^3 - 2*x + 1;
x = linspace(-2, 2, 200);

fig = figure('Visible', 'off', 'Position', [0 0 700 500]);
plot(x, f(x), 'LineWidth', 2);
xlabel('x'); ylabel('f(x)');
title('f(x) = x^3 - 2x + 1');
yline(0, 'k--');
save_png(fig, fullfile(out_dir, '03_anon_function.png'));

%% 2. 把函式當參數傳：fzero 求根
% fzero 第一個參數收 function handle
root = fzero(f, 1);
fprintf('在 x=1 附近找到的根：%.6f\n', root);
fprintf('驗證 f(root) = %.2e (應該接近 0)\n', f(root));

%% 3. 多回傳值
[m, idx] = my_max([3 1 4 1 5 9 2 6 5 3]);
fprintf('最大值 = %d，位置 = %d\n', m, idx);

%% 4. 把函式向量化：對矩陣每個元素套用
g = @(x) sin(x) ./ (x + 1e-9);   % 避免 0/0
[X, Y] = meshgrid(linspace(-5, 5, 100));
R = sqrt(X.^2 + Y.^2);
Z = g(R);

fig = figure('Visible', 'off', 'Position', [0 0 800 600]);
surf(X, Y, Z, 'EdgeColor', 'none');
colormap(turbo); colorbar;
xlabel('x'); ylabel('y'); zlabel('sin(r)/r');
title('匿名函式套用到整張網格 (無 for loop)');
view(45, 35);
save_png(fig, fullfile(out_dir, '03_vectorized.png'));

%% 5. 函式檔的慣例
% MATLAB 一個 .m 檔放一個 function 是最常見做法。
% my_max 被拆成同目錄下的 my_max.m，本 script 直接呼叫即可。
% （也可以把 local function 寫在 script 最後，但那需要用 MATLAB Editor 互動執行）
