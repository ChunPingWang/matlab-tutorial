%% 章節 02-4：複數與頻域 - Fourier 與 Laplace 直觀
% 為後面的 Bode、傳遞函數做準備
clear; close all;
out_dir = fullfile(fileparts(mfilename('fullpath')), '..', 'images');

%% 1. 複數基本：複平面與極座標
z1 = 3 + 4i;
fprintf('z = %s，|z| = %.2f，angle(z) = %.2f rad = %.1f deg\n', ...
        char(sym(z1)), abs(z1), angle(z1), rad2deg(angle(z1)));
% 共軛、實部、虛部
fprintf('conj(z) = %s\n', char(sym(conj(z1))));

%% 2. Euler 公式視覺化：e^{i theta} 就是單位圓
theta = linspace(0, 2*pi, 200);
ec = exp(1i*theta);

fig = figure('Visible', 'off', 'Position', [0 0 700 700]);
plot(real(ec), imag(ec), 'b-', 'LineWidth', 2); hold on;
% 標幾個典型角度
angles = [0, pi/4, pi/2, pi, 3*pi/2];
labels = {'0', '\pi/4', '\pi/2', '\pi', '3\pi/2'};
for k = 1:length(angles)
    pt = exp(1i*angles(k));
    plot([0 real(pt)], [0 imag(pt)], 'k--');
    plot(real(pt), imag(pt), 'ro', 'MarkerSize', 8, 'LineWidth', 2);
    text(1.1*real(pt), 1.1*imag(pt), labels{k}, 'FontSize', 12);
end
axis equal;
xlim([-1.5 1.5]); ylim([-1.5 1.5]);
xline(0, 'k:'); yline(0, 'k:');
xlabel('Re'); ylabel('Im');
title('e^{i\theta} = cos\theta + i sin\theta 在複平面是單位圓');
save_png(fig, fullfile(out_dir, '04_euler.png'));

%% 3. FFT：把時域訊號拆成頻率成份
% 合成一個訊號：50 Hz + 120 Hz 加雜訊
fs = 1000;              % 取樣率
T = 1;                  % 1 秒
t = (0:1/fs:T-1/fs)';
sig = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t) + 0.5*randn(size(t));

% FFT
Y = fft(sig);
L = length(sig);
P2 = abs(Y)/L;
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:L/2)/L;

fig = figure('Visible', 'off', 'Position', [0 0 1000 600]);
subplot(2,1,1);
plot(t(1:200), sig(1:200), 'b-', 'LineWidth', 1);
xlabel('t (s)'); ylabel('signal');
title('時域：50Hz + 120Hz + 雜訊（前 0.2 秒）');

subplot(2,1,2);
plot(f, P1, 'r-', 'LineWidth', 1.5);
xlim([0, 200]);
xlabel('頻率 (Hz)'); ylabel('|FFT|');
title('頻域：FFT 清楚分離出 50Hz 與 120Hz 兩個成份');
save_png(fig, fullfile(out_dir, '04_fft.png'));

%% 4. Laplace 變換概念：s = sigma + j*omega
% 為下章控制鋪墊：傳遞函數 H(s) 在 s 平面的圖
% 取 H(s) = 1 / (s^2 + 0.5s + 4)
% 在 s 平面畫 |H(s)|
[Re, Im] = meshgrid(linspace(-2, 0.5, 100), linspace(-4, 4, 100));
S = Re + 1i*Im;
H = 1 ./ (S.^2 + 0.5*S + 4);
mag = 20*log10(abs(H));

fig = figure('Visible', 'off', 'Position', [0 0 900 600]);
surf(Re, Im, mag, 'EdgeColor', 'none');
xlabel('Re(s)'); ylabel('Im(s)'); zlabel('|H(s)| dB');
title('|H(s)|_{dB} for H(s) = 1/(s^2 + 0.5s + 4)，極點是「山峰」');
view(45, 30);
colormap(turbo); colorbar;
zlim([-30, 30]);
% 標出極點
poles = roots([1, 0.5, 4]);
hold on;
for p = poles'
    plot3(real(p), imag(p), 25, 'rx', 'MarkerSize', 14, 'LineWidth', 3);
end
save_png(fig, fullfile(out_dir, '04_laplace_surface.png'));

%% 5. j*omega 軸切片 = Bode magnitude
% Bode 就是把 H(s) 限制在 s = j*omega 軸看 magnitude vs omega
omega = logspace(-1, 2, 500);
H_jw = 1 ./ ((1i*omega).^2 + 0.5*(1i*omega) + 4);

fig = figure('Visible', 'off', 'Position', [0 0 900 500]);
semilogx(omega, 20*log10(abs(H_jw)), 'LineWidth', 2);
xline(2, 'r--', '\omega_n = 2');
xlabel('\omega (rad/s)'); ylabel('|H(j\omega)| (dB)');
title('Bode magnitude：把 s = j\omega 代入 H(s)');
save_png(fig, fullfile(out_dir, '04_bode_mag.png'));
