function pathItems=getPathItemsForConstraints(h,blkObj)%#ok





    pathItems={};

    try
        blockDialogObj=feval(blkObj.dialogcontroller,...
        blkObj.handle,...
        blkObj.dialogcontrollerarg);
    catch
        blockDialogObj=[];
        BlkDialogParams=fieldnames(blkObj.DialogParameters);
    end

    if~ismethod(blockDialogObj,'DSPDDG')
        delete(blockDialogObj);
    elseif~(ismethod(blockDialogObj,'getFixptModeandWLParams'))
        BlkDialogParams=fieldnames(blkObj.DialogParameters);
        allBlkDialogParams=BlkDialogParams;
        if ismember('accumMode',allBlkDialogParams)
            pathItems=[pathItems,'Accumulator'];
        end
        if ismember('prodOutputMode',allBlkDialogParams)
            pathItems=[pathItems,'Product output'];
        end
        if ismember('memoryMode',allBlkDialogParams)
            pathItems=[pathItems,'State'];
        end
        if ismember('outputMode',allBlkDialogParams)
            pathItems=[pathItems,'Output'];
        end
        if ismember('firstCoeffMode',allBlkDialogParams)
            pathItems=[pathItems,'FirstCoeff'];
        end
        if ismember('secondCoeffMode',allBlkDialogParams)
            pathItems=[pathItems,'SecondCoeff'];
        end
        if ismember('interProdMode',allBlkDialogParams)
            pathItems=[pathItems,'Intermediate product'];
        end
        if ismember('tapSumMode',allBlkDialogParams)
            pathItems=[pathItems,'Tap sum'];
        end
    else
        BlkDialogParams=blockDialogObj.getFixptModeandWLParams;
    end

    if isempty(pathItems)
        isParamName=strfind(BlkDialogParams,'Mode');

        for i=1:length(BlkDialogParams)
            allBlkDialogParams=fieldnames(blkObj.DialogParameters);
            if~isempty(isParamName{i})&&ismember(BlkDialogParams{i},allBlkDialogParams)
                switch BlkDialogParams{i}
                case 'accumMode'
                    pathItems=[pathItems,'Accumulator'];%#ok
                case 'prodOutputMode'
                    pathItems=[pathItems,'Product output'];%#ok
                case 'memoryMode'
                    pathItems=[pathItems,'State'];%#ok
                case 'outputMode'
                    pathItems=[pathItems,'Output'];%#ok
                case 'firstCoeffMode'
                    pathItems=[pathItems,'FirstCoeff'];%#ok
                case 'secondCoeffMode'
                    pathItems=[pathItems,'SecondCoeff'];%#ok
                case 'interProdMode'
                    pathItems=[pathItems,'Intermediate product'];%#ok
                case 'tapSumMode'
                    pathItems=[pathItems,'Tap sum'];%#ok
                case 'prod1Mode'
                    pathItems=[pathItems,'Product 1'];%#ok
                case 'prod2Mode'
                    pathItems=[pathItems,'Product 2'];%#ok
                end
            end
        end
    end



