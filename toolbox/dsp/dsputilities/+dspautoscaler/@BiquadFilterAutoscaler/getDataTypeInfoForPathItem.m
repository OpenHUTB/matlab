function[signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=...
    getDataTypeInfoForPathItem(h,blkObj,pathItem)%#ok





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

    case{'FirstCoeff','Numerator coefficients','Coefficients','Denominator coefficients','Scale values'}
        if ismember('firstCoeffMode',allBlkDialogParams)
            prefixStr='firstCoeff';
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





        prefixStr='';
        paramNames=getParamsFromSignalName(pathItem);
        if paramNames.skipThisSignal
            return;
        end
        modeStr=paramNames.modeStr;
        mdCharIdx=strfind(modeStr,'Mode');
        if~isempty(mdCharIdx)
            prefixStr=modeStr(1:(mdCharIdx-1));
        end
    end

    signValStr='Signed';
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
                specifiedDTStr=sprintf('fixdt(1,%s)',wlValueStr);
            else

                flValueStr=blkObj.(flDlgStr);
                specifiedDTStr=sprintf('fixdt(1,%s,%s)',wlValueStr,flValueStr);
            end
        end
    end

end


function[paramNames]=getParamsFromSignalName(SignalName)



    paramNames.skipThisSignal=0;
    paramNames.unknownParam=0;

    switch SignalName
    case 'Numerator accumulator'
        paramNames.modeStr='accumMode';
        paramNames.wlStr='accumWordLength';
        paramNames.flStr='accumFracLength';

    case 'Numerator product output'
        paramNames.modeStr='prodOutputMode';
        paramNames.wlStr='prodOutputWordLength';
        paramNames.flStr='prodOutputFracLength';

    case 'Denominator accumulator'
        paramNames.modeStr='accumMode';
        paramNames.wlStr='accumWordLength';
        paramNames.flStr='denAccumFracLength';

    case 'Denominator product output'
        paramNames.modeStr='prodOutputMode';
        paramNames.wlStr='prodOutputWordLength';
        paramNames.flStr='denProdOutputFracLength';

    case 'Output'
        paramNames.modeStr='outputMode';
        paramNames.wlStr='outputWordLength';
        paramNames.flStr='outputFracLength';

    case{'State','Input state','Output state'}
        paramNames.modeStr='memoryMode';
        paramNames.wlStr='memoryWordLength';
        paramNames.flStr='memoryFracLength';

    case 'Numerator coefficients'
        paramNames.modeStr='firstCoeffMode';
        paramNames.wlStr='firstCoeffWordLength';
        paramNames.flStr='firstCoeffFracLength';

    case 'Denominator coefficients'
        paramNames.modeStr='firstCoeffMode';
        paramNames.wlStr='firstCoeffWordLength';
        paramNames.flStr='secondCoeffFracLength';

    case 'Scale values'
        paramNames.modeStr='firstCoeffMode';
        paramNames.wlStr='firstCoeffWordLength';
        paramNames.flStr='scaleValueFracLength';

    case 'Multiplicand'
        paramNames.modeStr='multiplicandMode';
        paramNames.wlStr='multiplicandWordLength';
        paramNames.flStr='multiplicandFracLength';

    case 'Section input'
        paramNames.modeStr='stageInputMode';
        paramNames.wlStr='stageInputWordLength';
        paramNames.flStr='stageInputFracLength';

    case 'Section output'
        paramNames.modeStr='stageOutputMode';
        paramNames.wlStr='stageOutputWordLength';
        paramNames.flStr='stageOutputFracLength';

    otherwise
        paramNames.unknownParam=1;
    end

end
