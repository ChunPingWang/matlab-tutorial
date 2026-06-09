function [m, idx] = my_max(v)
% MY_MAX 自寫的 max，多回傳值示範
    m = v(1);
    idx = 1;
    for k = 2:length(v)
        if v(k) > m
            m = v(k);
            idx = k;
        end
    end
end
