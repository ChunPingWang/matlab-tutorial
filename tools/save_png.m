function save_png(fig, filepath)
% SAVE_PNG  套用統一樣式並輸出 PNG
%   save_png(fig, filepath)
    figstyle(fig);
    if ~exist(fileparts(filepath), 'dir')
        mkdir(fileparts(filepath));
    end
    exportgraphics(fig, filepath, 'Resolution', 150);
    fprintf('  saved: %s\n', filepath);
    close(fig);
end
