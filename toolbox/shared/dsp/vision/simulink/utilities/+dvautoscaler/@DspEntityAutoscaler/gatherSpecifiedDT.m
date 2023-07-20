function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)




    specifiedDTStr='';
    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

    comments={};
    signValStr='Signed';

    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';



    tryToUseCommonSPCParamStr=false;
    try


        blockDialogObj=...
        feval(blkObj.dialogcontroller,...
        blkObj.handle,blkObj.DialogControllerArgs);
        paramNamesDdg=blockDialogObj.getParamsFromSignalName(pathItem);
        delete(blockDialogObj);

        if paramNamesDdg.skipThisSignal




            DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

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
        tryToUseCommonSPCParamStr=true;
    end

    if tryToUseCommonSPCParamStr

        [unknownParam,modeStr,wlStr,flStr]=getDspEntityAutoscalerDTParamSettings(blkObj,pathItem);
        if unknownParam
            return;
        end
        paramNames.modeStr=modeStr;
        paramNames.wlStr=wlStr;
        paramNames.flStr=flStr;
    end

    if h.isDataTypeFullyInherited(blkObj,pathItem)



        [~,~,~,specifiedDTStr,flStr,modeStr,wlStr]=h.getDataTypeInfoForPathItem(blkObj,pathItem);
        DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

        paramNames.wlStr=wlStr;
        paramNames.flStr=flStr;
        paramNames.modeStr=modeStr;
        return;
    else

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

        DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);
    end


    function[unknownParam,modeStr,wlStr,flStr]=getDspEntityAutoscalerDTParamSettings(~,pathItem)

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

        case{'FirstCoeff','Numerator coefficients','Coefficients'}
            wlStr='firstCoeffWordLength';
            flStr='firstCoeffFracLength';

        case{'SecondCoeff','Denominator coefficients'}
            wlStr='secondCoeffWordLength';
            flStr='secondCoeffFracLength';

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
            wlStr='stageIOWordLength';
            flStr='stageInFracLength';

        case 'Section output'
            wlStr='stageIOWordLength';
            flStr='stageOutFracLength';

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




