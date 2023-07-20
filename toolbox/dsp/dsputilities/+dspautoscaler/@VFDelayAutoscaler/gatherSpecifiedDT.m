function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)




    specifiedDTStr='';
    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);
    comments={};
    signValStr='Signed';
    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';

    if h.isDataTypeFullyInherited(blkObj,pathItem)



        [~,~,~,specifiedDTStr,flStr,modeStr,wlStr]=h.getDataTypeInfoForPathItem(blkObj,pathItem);

        paramNames.modeStr=modeStr;
        paramNames.wlStr=wlStr;
        paramNames.flStr=flStr;
    else

        isFarrowInterpMode=strcmp(blkObj.modeActive,'Farrow');
        if isFarrowInterpMode
            [unknownParam,wlStr,flStr,modeStr]=getVFDelayFarrowDTParamSettings(blkObj,pathItem);
        else

            [unknownParam,wlStr,flStr,modeStr]=getVFDelayLinFIRDTParamSettings(blkObj,pathItem);
        end
        paramNames.modeStr=modeStr;
        paramNames.wlStr=wlStr;
        paramNames.flStr=flStr;

        if unknownParam
            return;
        end

        if strcmp(pathItem,'Coefficients')
            if isempty(flStr)


                wlValueStr=blkObj.(wlStr);
                if strcmp(blkObj.modeActive,'Linear')

                    specifiedDTStr=h.getUDTStrFromFixPtInfo(blkObj,signValStr,wlValueStr,wlValueStr);
                    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);
                    return;
                else

                    specifiedDTStr=h.getUDTStrFromFixPtInfo(blkObj,signValStr,wlValueStr);
                    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);
                    return;
                end

            end
        end

        wlValueStr=blkObj.(wlStr);


        if isempty(wlValueStr)
            return;
        end

        if h.isDataTypeFracLengthOnlyInherited(blkObj,pathItem)
            specifiedDTStr=h.getUDTStrFromFixPtInfo(blkObj,signValStr,wlValueStr);
            DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

            return;
        else

            flValueStr=blkObj.(flStr);


            if isempty(flValueStr)
                return;
            else
                specifiedDTStr=h.getUDTStrFromFixPtInfo(blkObj,signValStr,wlValueStr,flValueStr);
            end
        end
    end

    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

end


function[unknownParam,wlStr,flStr,modeStr]=getVFDelayFarrowDTParamSettings(blkObj,pathItem)



    [unknownParam,wlStr,flStr]=getVFDelayLinFIRDTParamSettings(blkObj,pathItem);

    if unknownParam
        unknownParam=0;

        switch pathItem
        case 'Product output polyval'
            wlStr='interProdWordLength';
            flStr='interProdFracLength';

        case 'Accumulator polyval'
            wlStr='secondCoeffWordLength';
            flStr='secondCoeffFracLength';

        case 'Multiplicand polyval'
            wlStr='memoryWordLength';
            flStr='memoryFracLength';

        otherwise
            unknownParam=1;
            wlStr='';
            flStr='';
        end
    end

    if unknownParam
        modeStr='';
    else
        endIdx=regexp(wlStr,'WordLength$')-1;
        prefixStr=wlStr(1:endIdx);
        modeStr=strcat(prefixStr,'Mode');
    end

end


function[unknownParam,wlStr,flStr,modeStr]=getVFDelayLinFIRDTParamSettings(blkObj,pathItem)%#ok

    unknownParam=0;

    switch pathItem
    case 'Coefficients'
        wlStr='firstCoeffWordLength';
        flStr='';

    case 'Product output'
        wlStr='prodOutputWordLength';
        flStr='prodOutputFracLength';

    case 'Accumulator'
        wlStr='accumWordLength';
        flStr='accumFracLength';

    case{'Output','1'}
        wlStr='outputWordLength';
        flStr='outputFracLength';

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



