function figstyle(fig)
% FIGSTYLE  教程統一的圖樣式設定
%   figstyle(fig) 套用大字體、寬線、淺灰格線
%   fig 為 figure handle
    set(fig, 'Color', 'w');
    ax_list = findall(fig, 'Type', 'axes');
    for k = 1:length(ax_list)
        ax = ax_list(k);
        ax.FontSize = 12;
        ax.LineWidth = 1.0;
        ax.GridAlpha = 0.25;
        ax.Box = 'on';
        grid(ax, 'on');
    end
    lines = findall(fig, 'Type', 'line');
    for k = 1:length(lines)
        if lines(k).LineWidth < 1.2
            lines(k).LineWidth = 1.5;
        end
    end
end
