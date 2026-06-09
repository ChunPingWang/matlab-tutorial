%% 章節 02-3：線性代數 - 控制系統的根基
% 解線性方程組、特徵值、SVD、矩陣分解
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% 1. 解線性方程組 A x = b
A = [3 2 -1;
     2 -1 3;
     1 0 2];
b = [1; -2; 4];

% 千萬不要寫 inv(A) * b，數值上很差
x = A \ b;            % 反斜線：解 A*x = b 的標準寫法
fprintf('解 x = [%.4f, %.4f, %.4f]\n', x);
fprintf('檢查 A*x - b 範數 = %.2e\n', norm(A*x - b));

%% 2. 特徵值與特徵向量
% 控制理論最重要的工具
A_dyn = [0 1; -4 -0.5];     % 對應 x'' + 0.5 x' + 4 x = 0 的狀態矩陣
[V, D] = eig(A_dyn);
fprintf('特徵值 = %s\n', mat2str(diag(D), 4));
fprintf('（實部負 -> 穩定；虛部非零 -> 振盪）\n');

%% 3. 視覺化：特徵向量是「不轉只縮放」的方向
% 用 2x2 對稱矩陣
M = [2 1; 1 3];
[V, D] = eig(M);

% 產生單位圓上的點，看 M 怎麼把圓壓成橢圓
theta = linspace(0, 2*pi, 100);
circle = [cos(theta); sin(theta)];
ellipse = M * circle;

fig = figure('Visible', 'off', 'Position', [0 0 800 700]);
plot(circle(1,:), circle(2,:), 'b-', 'LineWidth', 2); hold on;
plot(ellipse(1,:), ellipse(2,:), 'r-', 'LineWidth', 2);

% 畫特徵向量（縮放後）
for i = 1:2
    v = V(:,i);
    lam = D(i,i);
    quiver(0, 0, v(1), v(2), 'k', 'LineWidth', 2, ...
           'MaxHeadSize', 0.5, 'AutoScale', 'off');
    quiver(0, 0, lam*v(1), lam*v(2), 'm', 'LineWidth', 2, ...
           'MaxHeadSize', 0.3, 'AutoScale', 'off');
    text(1.1*v(1), 1.1*v(2), sprintf('v_%d', i), 'FontSize', 14);
    text(1.1*lam*v(1), 1.1*lam*v(2), sprintf('\\lambda_%d v_%d', i, i), ...
         'FontSize', 14, 'Color', 'm');
end

axis equal;
xlim([-4 4]); ylim([-4 4]);
xlabel('x'); ylabel('y');
title(sprintf('M = [2 1; 1 3]，特徵值 = (%.2f, %.2f)', D(1,1), D(2,2)));
legend({'單位圓', 'M*圓 (橢圓)', '特徵向量 v', '\lambda v'}, 'Location', 'southeast');
save_png(fig, fullfile(out_dir, '03_eigenvectors.png'));

%% 4. SVD：奇異值分解
% 任意矩陣都能分解成 U*S*V'，工程上用來做降秩、最小平方
A = magic(8);
[U, S, V] = svd(A);
sv = diag(S);
fprintf('magic(8) 的奇異值：\n');
disp(sv');

fig = figure('Visible', 'off', 'Position', [0 0 800 500]);
semilogy(sv, 'o-', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('index'); ylabel('singular value (log)');
title('magic(8) 的奇異值快速衰減 -> 此矩陣可低秩逼近');
save_png(fig, fullfile(out_dir, '03_svd.png'));

%% 5. 條件數：解 Ax=b 的數值穩定性
% Hilbert 矩陣是「病態 (ill-conditioned)」的經典例
fprintf('\nHilbert 矩陣條件數隨大小變化：\n');
ns = 2:12;
conds = zeros(size(ns));
for i = 1:length(ns)
    H = hilb(ns(i));
    conds(i) = cond(H);
end

fig = figure('Visible', 'off', 'Position', [0 0 800 500]);
semilogy(ns, conds, 'o-', 'LineWidth', 2, 'MarkerSize', 8);
yline(1e16, 'r--', 'double precision 極限');
xlabel('矩陣大小 n'); ylabel('cond(H_n) (log)');
title('Hilbert 矩陣條件數爆炸成長 -> 數值上幾乎不可解');
save_png(fig, fullfile(out_dir, '03_hilbert_cond.png'));
