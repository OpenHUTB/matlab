function[signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)





    allBlkDialogParams=fieldnames(blkObj.DialogParameters);

    switch pathItem
    case{'Output','1'}
        if ismember('outputMode',allBlkDialogParams)
            prefixStr='output';
        end

    case 'Accumulator'
        if ismember('accumMode',allBlkDialogParams)
            prefixStr='accum';
        end

    case 'Product output'
        if ismember('prodOutputMode',allBlkDialogParams)
            prefixStr='prodOutput';
        end

    case 'State'
        if ismember('memoryMode',allBlkDialogParams)
            prefixStr='memory';
        end

    case{'FirstCoeff','Numerator coefficients','Coefficients'}
        if ismember('firstCoeffMode',allBlkDialogParams)
            prefixStr='firstCoeff';
        end

    case{'SecondCoeff','Denominator coefficients'}
        if ismember('secondCoeffMode',allBlkDialogParams)
            prefixStr='secondCoeff';
        end

    case 'Intermediate product'
        if ismember('interProdMode',allBlkDialogParams)
            prefixStr='interProd';
        end

    case 'Tap sum'
        if ismember('tapSumMode',allBlkDialogParams)
            prefixStr='tapSum';
        end

    case 'Multiplicand'
        if ismember('multiplicandMode',allBlkDialogParams)
            prefixStr='multiplicand';
        end

    case 'Section input'
        if ismember('stageInputMode',allBlkDialogParams)
            prefixStr='stageInput';
        elseif ismember('stageInMode',allBlkDialogParams)
            prefixStr='stageIn';
        elseif ismember('stageIOMode',allBlkDialogParams)
            prefixStr='stageIO';
        end

    case 'Section output'
        if ismember('stageOutputMode',allBlkDialogParams)
            prefixStr='stageOutput';
        elseif ismember('stageOutMode',allBlkDialogParams)
            prefixStr='stageOut';
        elseif ismember('stageIOMode',allBlkDialogParams)
            prefixStr='stageIO';
        end

    case 'Denominator accumulator'
        if ismember('denAccumMode',allBlkDialogParams)
            prefixStr='denAccum';
        elseif ismember('accumMode',allBlkDialogParams)
            prefixStr='accum';
        end

    case 'Denominator product output'
        if ismember('denProdMode',allBlkDialogParams)
            prefixStr='denProd';
        elseif ismember('prodOutputMode',allBlkDialogParams)
            prefixStr='prodOutput';
        end

    otherwise






        try
            prefixStr='';

            blockDialogObj=feval(blkObj.dialogcontroller,...
            blkObj.handle,...
            blkObj.dialogcontrollerarg);

            if(ismethod(blockDialogObj,'getParamsFromSignalName'))
                paramNames=blockDialogObj.getParamsFromSignalName(pathItem);
                if paramNames.skipThisSignal
                    return;
                end
                modeStr=paramNames.modeStr;
                mdCharIdx=strfind(modeStr,'Mode');
                if~isempty(mdCharIdx)
                    prefixStr=modeStr(1:(mdCharIdx-1));
                end
            end
        catch %#ok
            blockDialogObj=[];
        end
        delete(blockDialogObj);
    end

    signValStr=h.getInportSignednessString(blkObj);
    wlValueStr='';
    flValueStr='';
    specifiedDTStr='';
    flDlgStr='';
    wlDlgStr='';
    modeDlgStr='';

    if~isempty(prefixStr)
        modeDlgStr=strcat(prefixStr,'Mode');
        specifiedDTStr=blkObj.(modeDlgStr);
        wlDlgStr=strcat(prefixStr,'WordLength');


        if strcmpi(modeDlgStr,'stageIOMode')
            if strcmpi(pathItem,'Section input')
                flDlgStr='stageInFracLength';
            else
                flDlgStr='stageOutFracLength';
            end
        else

            flDlgStr=strcat(prefixStr,'FracLength');
        end

        if isempty(regexp(specifiedDTStr,'^(Inherit |Inherit:|Same as|Same word|Smallest )','ONCE'))

            wlValueStr=blkObj.(wlDlgStr);
            if strcmpi(specifiedDTStr,'Specify word length')

                flValueStr='Best precision';
                if strcmpi(signValStr,'Unsigned')
                    specifiedDTStr=sprintf('fixdt(0,%s)',wlValueStr);
                elseif strcmpi(signValStr,'Signed')
                    specifiedDTStr=sprintf('fixdt(1,%s)',wlValueStr);
                else
                    specifiedDTStr=sprintf('fixdt([],%s)',wlValueStr);
                end
            else

                flValueStr=blkObj.(flDlgStr);
                if strcmpi(signValStr,'Unsigned')
                    specifiedDTStr=sprintf('fixdt(0,%s,%s)',wlValueStr,flValueStr);
                elseif strcmpi(signValStr,'Signed')
                    specifiedDTStr=sprintf('fixdt(1,%s,%s)',wlValueStr,flValueStr);
                else
                    specifiedDTStr=sprintf('fixdt([],%s,%s)',wlValueStr,flValueStr);
                end
            end
        end
    end


