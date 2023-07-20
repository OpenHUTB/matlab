function pathItems=getPathItems(h,blkObj)%#ok







    if strfind(blkObj.V_Source,'param')
        pathItems={'Vector (V)','Output'};
    else
        pathItems={'Output'};
    end


    blkDialogParams=fieldnames(blkObj.DialogParameters);
    if ismember('prodOutputDataTypeStr',blkDialogParams)
        pathItems=[pathItems,'Product output'];
    end


    if ismember('accumDataTypeStr',blkDialogParams)
        pathItems=[pathItems,'Accumulator'];
    end
