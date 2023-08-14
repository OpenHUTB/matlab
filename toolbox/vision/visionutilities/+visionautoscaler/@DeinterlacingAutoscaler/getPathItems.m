function pathItems=getPathItems(h,blkObj)%#ok








    hasFixptTabParams=strncmp(blkObj.method,'Linear ...',6);

    if(hasFixptTabParams)
        pathItems={'Accumulator',...
        'Output'};
    else
        pathItems={};
    end


