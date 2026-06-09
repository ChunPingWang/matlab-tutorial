function dydt = double_pendulum_rhs(~, y, p)
% 雙擺 ODE 右手側
% y = [theta1; theta2; omega1; omega2]
% p: struct with fields g, m1, m2, L1, L2
    th1 = y(1); th2 = y(2);
    w1 = y(3);  w2 = y(4);
    g = p.g; m1 = p.m1; m2 = p.m2; L1 = p.L1; L2 = p.L2;

    delta = th1 - th2;
    M = m1 + m2;

    den1 = M*L1 - m2*L1*cos(delta)^2;
    den2 = (L2/L1) * den1;

    dw1 = (m2*L1*w1^2*sin(delta)*cos(delta) ...
         + m2*g*sin(th2)*cos(delta) ...
         + m2*L2*w2^2*sin(delta) ...
         - M*g*sin(th1)) / den1;

    dw2 = (-m2*L2*w2^2*sin(delta)*cos(delta) ...
         + M*g*sin(th1)*cos(delta) ...
         - M*L1*w1^2*sin(delta) ...
         - M*g*sin(th2)) / den2;

    dydt = [w1; w2; dw1; dw2];
end
