function[min,max]=gatherDesignMinMax(h,blkObj,pathItem)%#ok





    idx=blkObj.leafChildName2IndexMap(pathItem);
    min=blkObj.designMins{idx};
    max=blkObj.designMaxs{idx};

    if min==-inf
        min=[];
    end

    if max==inf
        max=[];
    end


