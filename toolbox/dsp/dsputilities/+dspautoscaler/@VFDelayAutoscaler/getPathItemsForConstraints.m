function pathItems=getPathItemsForConstraints(h,blkObj)%#ok





    BlkDialogParams=fieldnames(blkObj.DialogParameters);
    isParamName=strfind(BlkDialogParams,'Mode');

    for i=1:length(BlkDialogParams)
        allBlkDialogParams=fieldnames(blkObj.DialogParameters);
        if~isempty(isParamName{i})&&ismember(BlkDialogParams{i},allBlkDialogParams)
            switch BlkDialogParams{i}
            case 'firstCoeffMode'
                pathItems='Coefficients';
            case 'prodOutputMode'
                pathItems='Product output';
            case 'accumMode'
                pathItems='Accumulator';
            case 'outputMode'
                pathItems='Output';
            case 'interProdMode'
                pathItems='Product output polyval';
            case 'secondCoeffMode'
                pathItems='Accumulator polyval';
            case 'memoryMode'
                pathItems='Multiplicand polyval';
            otherwise
                pathItems='';
            end
        end
    end
