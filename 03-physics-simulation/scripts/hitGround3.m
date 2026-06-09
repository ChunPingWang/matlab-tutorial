function [value, isterminal, direction] = hitGround3(~, s)
% 拋體落地事件：y=0 且下降中即停
    value = s(2);
    isterminal = 1;
    direction = -1;
end
