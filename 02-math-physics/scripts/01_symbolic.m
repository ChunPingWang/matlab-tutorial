%% 章節 02-1：符號運算 (Symbolic Math Toolbox)
% 微分、積分、解方程、泰勒展開 - 工程上推導常用
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% 1. 宣告符號變數
syms x t omega m k c

%% 2. 微分
f = sin(x)^2 + exp(-x);
df = diff(f, x);
d2f = diff(f, x, 2);
fprintf('f(x)  = %s\n', char(f));
fprintf('df/dx = %s\n', char(df));
fprintf('d2f/dx2 = %s\n', char(d2f));

%% 3. 積分（不定 + 定積分）
g = x * exp(-x^2);
G = int(g, x);
fprintf('∫ x*exp(-x^2) dx = %s\n', char(G));
G_def = int(g, x, 0, inf);
fprintf('∫_0^∞ x*exp(-x^2) dx = %s = %.4f\n', char(G_def), double(G_def));

%% 4. 解代數方程
% 二次方程一般解
syms a b c_var
sol = solve(a*x^2 + b*x + c_var == 0, x);
disp('ax^2 + bx + c = 0 的根：');
disp(sol);

%% 5. 解 ODE：彈簧質量阻尼系統
% m*x''(t) + c*x'(t) + k*x(t) = 0
% 用符號運算求解析解
syms x_t(t) m_v c_v k_v
eqn = m_v*diff(x_t, t, 2) + c_v*diff(x_t, t) + k_v*x_t == 0;
% 帶入具體數值
eqn_num = subs(eqn, [m_v, c_v, k_v], [1, 0.5, 4]);
% 初始條件：x(0)=1, x'(0)=0
Dx = diff(x_t, t);
cond = [x_t(0) == 1, subs(Dx, t, 0) == 0];
sol_t = dsolve(eqn_num, cond);
sol_t = simplify(sol_t);
fprintf('彈簧質量阻尼解析解：\n');
disp(sol_t);

% 畫出解
fig = figure('Visible', 'off', 'Position', [0 0 800 500]);
fplot(sol_t, [0 10], 'LineWidth', 2);
xlabel('t (s)'); ylabel('x(t)');
title('彈簧質量阻尼系統的解析解 (m=1, c=0.5, k=4, x(0)=1)');
save_png(fig, fullfile(out_dir, '01_sym_spring.png'));

%% 6. 泰勒展開
syms y
ts = taylor(cos(y), y, 'Order', 8);
fprintf('cos(y) 泰勒展開到 y^7：\n%s\n', char(ts));

fig = figure('Visible', 'off', 'Position', [0 0 800 500]);
fplot(cos(y), [-2*pi, 2*pi], 'b-', 'LineWidth', 2); hold on;
fplot(taylor(cos(y), y, 'Order', 4), [-2*pi, 2*pi], 'r--', 'LineWidth', 1.5);
fplot(taylor(cos(y), y, 'Order', 8), [-2*pi, 2*pi], 'g-.', 'LineWidth', 1.5);
fplot(taylor(cos(y), y, 'Order', 12), [-2*pi, 2*pi], 'm:', 'LineWidth', 1.5);
ylim([-2, 2]);
legend({'cos(y) 真值', 'Taylor O(y^3)', 'Taylor O(y^7)', 'Taylor O(y^{11})'}, ...
       'Location', 'south');
xlabel('y'); ylabel('value');
title('泰勒展開逐階逼近 cos(y)');
save_png(fig, fullfile(out_dir, '01_taylor.png'));
