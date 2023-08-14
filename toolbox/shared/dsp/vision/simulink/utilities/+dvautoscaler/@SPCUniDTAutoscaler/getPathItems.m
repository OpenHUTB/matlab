function pathItems=getPathItems(h,blkObj)%#ok





    pathItems={};

    BlkDialogParams=fieldnames(blkObj.DialogParameters);






    if ismember('accumDataTypeStr',BlkDialogParams)
        pathItems=[pathItems,'Accumulator'];
    end

    if ismember('prodOutputDataTypeStr',BlkDialogParams)
        pathItems=[pathItems,'Product output'];
    end

    if ismember('memoryDataTypeStr',BlkDialogParams)
        pathItems=[pathItems,'State'];
    end

    if ismember('outputDataTypeStr',BlkDialogParams)
        pathItems=[pathItems,'Output'];
    end

    if ismember('interProdDataTypeStr',BlkDialogParams)
        pathItems=[pathItems,'Intermediate product'];
    end

    if ismember('tapSumDataTypeStr',BlkDialogParams)
        pathItems=[pathItems,'Tap sum'];
    end


