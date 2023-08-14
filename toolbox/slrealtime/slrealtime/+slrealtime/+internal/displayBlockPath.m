function blockPathStr=displayBlockPath(blockpath)














    if iscell(blockpath)
        blockPathStr=blockpath{1};
        for i=2:length(blockpath)
            blockPathStr=strcat(blockPathStr,'/',extractAfter(blockpath{i},'/'));
        end
    else
        blockPathStr=blockpath;
    end
