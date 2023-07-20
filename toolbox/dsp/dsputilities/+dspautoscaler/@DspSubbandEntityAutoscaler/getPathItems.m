function pathItems=getPathItems(h,blkObj)%#ok




    switch blkObj.MaskType
    case ''
        pathItems={'Accumulator','Product output','Output','FirstCoeff'};
    otherwise
        pathItems={};
    end




