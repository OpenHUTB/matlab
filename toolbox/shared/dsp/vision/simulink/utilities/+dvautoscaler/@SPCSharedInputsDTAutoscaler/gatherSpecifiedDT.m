function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)




    specifiedDTStr='';
    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);
    comments={};
    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';

    blockDialogObj=feval(blkObj.dialogcontroller,...
    blkObj.handle,...
    blkObj.dialogcontrollerarg);


    tryToUseCommonSPCParamStr=false;
    try
        paramNamesDdg=blockDialogObj.getParamsFromSignalName(pathItem);
        delete(blockDialogObj);
        if paramNamesDdg.skipThisSignal




            return;
        end
        if paramNamesDdg.unknownParam
            tryToUseCommonSPCParamStr=true;
        else
            paramNames.modeStr=paramNamesDdg.modeStr;
            paramNames.wlStr=paramNamesDdg.wlStr;
            paramNames.flStr=paramNamesDdg.flStr;
        end
    catch
        delete(blockDialogObj);
        tryToUseCommonSPCParamStr=true;
    end

    if tryToUseCommonSPCParamStr

        [unknownParam,wlStr,flStr,modeStr]=getDspEntityAutoscalerDTParamSettings(blkObj,pathItem);
        if unknownParam
            return;
        end
        paramNames.wlStr=wlStr;
        paramNames.flStr=flStr;
        paramNames.modeStr=modeStr;
    end

    if h.isDataTypeFullyInherited(blkObj,pathItem)



        [~,~,~,specifiedDTStr,flStr,modeStr,wlStr]=h.getDataTypeInfoForPathItem(blkObj,pathItem);

        DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);
        paramNames.wlStr=wlStr;
        paramNames.flStr=flStr;
        paramNames.modeStr=modeStr;
        return;
    else

        signValStr=h.getInportSignednessString(blkObj);


        wlString=paramNames.wlStr;
        wlValueStr=blkObj.(wlString);


        if isempty(wlValueStr)
            return;
        end

        if h.isDataTypeFracLengthOnlyInherited(blkObj,pathItem)
            specifiedDTStr=h.getUDTStrFromFixPtInfo(blkObj,signValStr,wlValueStr);
            DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

            return;
        else

            flString=paramNames.flStr;
            flValueStr=blkObj.(flString);


            if isempty(flValueStr)
                return;
            else
                specifiedDTStr=h.getUDTStrFromFixPtInfo(blkObj,signValStr,wlValueStr,flValueStr);
            end
        end
    end

    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

end


function[unknownParam,wlStr,flStr,modeStr]=getDspEntityAutoscalerDTParamSettings(blkObj,pathItem)

    unknownParam=0;

    switch pathItem

    case{'Accumulator','Numerator accumulator'}
        wlStr='accumWordLength';
        flStr='accumFracLength';

    case{'Product output','Numerator product output'}
        wlStr='prodOutputWordLength';
        flStr='prodOutputFracLength';

    case 'State'
        wlStr='memoryWordLength';
        flStr='memoryFracLength';

    case{'Output'}
        wlStr='outputWordLength';
        flStr='outputFracLength';

    case 'FirstCoeff'
        wlStr='firstCoeffWordLength';
        flStr='firstCoeffFracLength';

    case 'Intermediate product'
        wlStr='interProdWordLength';
        flStr='interProdFracLength';

    case 'Tap sum'
        wlStr='tapSumWordLength';
        flStr='tapSumFracLength';

    case 'Multiplicand'
        wlStr='multiplicandWordLength';
        flStr='multiplicandFracLength';

    case 'Section input'
        if strcmpi(blkObj.MaskType,'Biquad Filter')
            wlStr='stageInputWordLength';
            flStr='stageInputFracLength';
        else
            wlStr='stageIOWordLength';
            flStr='stageInFracLength';
        end

    case 'Section output'
        if strcmpi(blkObj.MaskType,'Biquad Filter')
            wlStr='stageOutputWordLength';
            flStr='stageOutputFracLength';
        else
            wlStr='stageIOWordLength';
            flStr='stageOutFracLength';
        end

    case 'Denominator accumulator'
        wlStr='accumWordLength';
        flStr='denAccumFracLength';

    case 'Denominator product output'
        wlStr='prodOutputWordLength';
        flStr='denProdOutputFracLength';

    otherwise
        unknownParam=1;
        wlStr='';
        flStr='';
    end

    if unknownParam
        modeStr='';
    else
        endIdx=regexp(wlStr,'WordLength$')-1;
        prefixStr=wlStr(1:endIdx);
        modeStr=strcat(prefixStr,'Mode');
    end

end




