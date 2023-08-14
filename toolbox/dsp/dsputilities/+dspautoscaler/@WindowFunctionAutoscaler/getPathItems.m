function pathItems=getPathItems(h,blkObj)%#ok





    if strcmpi(blkObj.winmode,'Generate window')
        pathItems={'Window'};
    else
        pathItems={'Window',...
        'Product output',...
        'Output'};
    end


