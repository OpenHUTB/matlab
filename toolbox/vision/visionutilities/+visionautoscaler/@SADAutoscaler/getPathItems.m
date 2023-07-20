function pathItems=getPathItems(h,blkObj)%#ok





    pathItems={'Accumulator'};

    if strcmp(blkObj.output,'SAD values')
        pathItems{end+1}='Output';
    elseif strcmp(blkObj.nearbyPel,'on')
        pathItems{end+1}='Output';
    end


