%% 章節 01-4：控制流與向量化
% if / for / while；以及如何盡量避免 for loop
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% 1. for loop 寫法
N = 1000;
y_loop = zeros(1, N);
tic;
for k = 1:N
    y_loop(k) = sin(k/100) * exp(-k/500);
end
t_loop = toc;

%% 2. 向量化寫法（一行）
k = 1:N;
tic;
y_vec = sin(k/100) .* exp(-k/500);
t_vec = toc;

fprintf('for loop：%.4f ms\n', t_loop*1000);
fprintf('向量化  ：%.4f ms\n', t_vec*1000);
fprintf('結果是否一致：%d\n', isequal(y_loop, y_vec));

%% 3. 條件邏輯：把 piecewise 函式用邏輯索引而不是 if
x = linspace(-3, 3, 500);
% 想實作  y = x^2  (x<0)  和  y = sin(2*x)  (x>=0)
y = zeros(size(x));
y(x < 0) = x(x < 0).^2;
y(x >= 0) = sin(2*x(x >= 0));

fig = figure('Visible', 'off', 'Position', [0 0 800 500]);
plot(x, y, 'LineWidth', 2);
xline(0, 'k--');
xlabel('x'); ylabel('y');
title('用邏輯索引實作 piecewise 函式（沒有任何 if）');
legend({'y(x)'}, 'Location', 'northwest');
save_png(fig, fullfile(out_dir, '04_piecewise.png'));

%% 4. while loop：收斂判斷
% 牛頓法解 x^2 = 2
x = 1.0;
tol = 1e-10;
iters = 0;
history = x;
while abs(x^2 - 2) > tol && iters < 100
    x = x - (x^2 - 2) / (2*x);   % Newton step
    iters = iters + 1;
    history(end+1) = x;          %#ok<SAGROW>
end
fprintf('牛頓法收斂到 sqrt(2) ≈ %.12f，疊代 %d 次\n', x, iters);

fig = figure('Visible', 'off', 'Position', [0 0 700 500]);
semilogy(0:length(history)-1, abs(history - sqrt(2)) + 1e-16, 'o-', 'LineWidth', 2);
xlabel('疊代次數'); ylabel('|x_k - \surd 2| (log)');
title('牛頓法二次收斂示範');
save_png(fig, fullfile(out_dir, '04_newton_convergence.png'));
