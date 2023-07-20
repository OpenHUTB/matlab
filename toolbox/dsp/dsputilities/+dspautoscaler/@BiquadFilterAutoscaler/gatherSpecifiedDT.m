function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)




    specifiedDTStr='';
    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);
    comments={};
    signValStr='Signed';
    unknownParam=0;

    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';

    switch pathItem
    case 'Section input'
        wlStr='stageInputWordLength';
        flStr='stageInputFracLength';

    case 'Section output'
        wlStr='stageOutputWordLength';
        flStr='stageOutputFracLength';

    case 'Numerator product output'


        wlStr='prodOutputWordLength';
        flStr='prodOutputFracLength';

    case 'Denominator product output'


        wlStr='prodOutputWordLength';
        flStr='denProdOutputFracLength';

    case 'Numerator accumulator'


        wlStr='accumWordLength';
        flStr='accumFracLength';

    case 'Denominator accumulator'


        wlStr='accumWordLength';
        flStr='denAccumFracLength';

    case 'Output'
        wlStr='outputWordLength';
        flStr='outputFracLength';

    case 'State'
        wlStr='memoryWordLength';
        flStr='memoryFracLength';

    case 'Multiplicand'
        wlStr='multiplicandWordLength';
        flStr='multiplicandFracLength';

    case 'Numerator coefficients'


        wlStr='firstCoeffWordLength';
        flStr='firstCoeffFracLength';

    case 'Denominator coefficients'


        wlStr='firstCoeffWordLength';
        flStr='secondCoeffFracLength';

    case 'Scale values'


        wlStr='firstCoeffWordLength';
        flStr='scaleValueFracLength';

    otherwise
        unknownParam=1;
        wlStr='';
        flStr='';
    end
    if unknownParam
        return;
    end

    endIdx=regexp(wlStr,'WordLength$')-1;
    prefixStr=wlStr(1:endIdx);
    modeStr=strcat(prefixStr,'Mode');

    paramNames.modeStr=modeStr;
    paramNames.wlStr=wlStr;
    paramNames.flStr=flStr;

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


        if~isempty(wlValueStr)

            if h.isDataTypeFracLengthOnlyInherited(blkObj,pathItem)
                specifiedDTStr=h.getUDTStrFromFixPtInfo(blkObj,signValStr,wlValueStr);

            else

                flString=paramNames.flStr;
                flValueStr=blkObj.(flString);


                if~isempty(flValueStr)
                    specifiedDTStr=h.getUDTStrFromFixPtInfo(blkObj,signValStr,wlValueStr,flValueStr);
                end
            end

        end

    end

    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

end





