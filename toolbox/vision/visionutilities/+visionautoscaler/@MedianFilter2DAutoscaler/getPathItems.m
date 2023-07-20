function pathItems=getPathItems(h,blkObj)%#ok










    if(hasFixptTabParameters(h,blkObj))
        pathItems={'Accumulator',...
        'Output'};
    else
        pathItems={};
    end


