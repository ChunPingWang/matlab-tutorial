%% 章節 01-1：向量與矩陣
% 教學重點：colon 運算子、索引從 1 開始、矩陣 vs 逐元素運算
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% 1. 建立向量
% colon (:) 是 MATLAB 最常用的運算子之一
v1 = 0:0.1:2*pi;            % start:step:stop，含端點若整除得到
v2 = linspace(0, 2*pi, 100); % 100 個點等分 [0, 2*pi]
fprintf('v1 長度 = %d, v2 長度 = %d\n', length(v1), length(v2));

%% 2. 索引從 1 開始（不是 0）
A = magic(4);   % 4x4 的魔方陣
disp('A =');
disp(A);
fprintf('A(1,1) = %d   <- 第一列第一行\n', A(1,1));
fprintf('A(end, end) = %d   <- end 代表最後\n', A(end, end));
disp('A(:, 2) 取第 2 行（colon 代表整列）：');
disp(A(:, 2));
disp('A(2:3, [1 4]) 取第 2~3 列、第 1 與 4 行：');
disp(A(2:3, [1 4]));

%% 3. 矩陣運算 vs 逐元素運算
B = [1 2; 3 4];
C = [5 6; 7 8];
disp('B * C  (矩陣乘法)：');
disp(B * C);
disp('B .* C  (逐元素相乘，注意點)：');
disp(B .* C);
disp('B^2  =  B*B：');
disp(B^2);
disp('B.^2  逐元素平方：');
disp(B.^2);

%% 4. 廣播（implicit expansion）
% MATLAB R2016b 起支援自動 broadcast
row = [1 2 3];      % 1x3
col = [10; 20; 30]; % 3x1
disp('row + col （3x3 廣播結果）：');
disp(row + col);

%% 5. 視覺化矩陣：把 magic 畫成熱圖
fig = figure('Visible', 'off', 'Position', [0 0 700 600]);
M = magic(20);
imagesc(M);
axis equal tight;
colormap(parula);
colorbar;
title('magic(20) - MATLAB 把矩陣當熱圖畫');
xlabel('行 (column)'); ylabel('列 (row)');
save_png(fig, fullfile(out_dir, '01_magic_heatmap.png'));

%% 6. 邏輯索引：找出大於 200 的元素
fig = figure('Visible', 'off', 'Position', [0 0 700 600]);
M = magic(20);
mask = M > 200;
M_highlight = double(mask) .* M;
imagesc(M_highlight);
axis equal tight;
colormap(hot);
colorbar;
title('邏輯索引：M > 200 的元素');
xlabel('行'); ylabel('列');
save_png(fig, fullfile(out_dir, '01_logical_mask.png'));
fprintf('M 中有 %d 個元素 > 200\n', nnz(mask));
