function pathItems=getPathItems(h,blkObj)%#ok








    pathItems={'Product output','Accumulator','Output'};

    if strcmp(blkObj.outQU,'on')

        pathItems=cat(2,pathItems,{'Output Q(U)'});
    end

    if strcmp(blkObj.outQError,'on')

        pathItems=cat(2,pathItems,{'Output D(QERR)'});
    end
