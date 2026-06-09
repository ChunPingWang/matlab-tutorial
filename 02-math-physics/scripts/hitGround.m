function [value, isterminal, direction] = hitGround(~, s)
% HITGROUND  ode45 事件函式：拋體 y=0 且下降中即停止
%   s = [x; y; vx; vy]
    value = s(2);        % 監看 y
    isterminal = 1;      % 觸發即停
    direction = -1;      % 只在「由正轉負」方向觸發
end
