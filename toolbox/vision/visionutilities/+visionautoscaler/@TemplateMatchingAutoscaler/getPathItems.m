function pathItems=getPathItems(h,blkObj)%#ok





    pathItems={};

    if strcmp(blkObj.metric,'Sum of squared differences')
        pathItems{end+1}='Product output';
    end

    pathItems{end+1}='Accumulator';

    if strcmp(blkObj.output,'Metric matrix')
        pathItems{end+1}='Output';
    elseif strcmp(blkObj.nMetric,'on')
        pathItems{end+1}='Output';
    end


