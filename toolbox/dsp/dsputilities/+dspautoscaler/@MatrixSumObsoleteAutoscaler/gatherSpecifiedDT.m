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

        [unknownParam,wlStr,flStr,modeStr]=getMatrixSumDTParamSettings(blkObj,pathItem);
        paramNames.modeStr=modeStr;
        paramNames.wlStr=wlStr;
        paramNames.flStr=flStr;

        if unknownParam
            return;
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


function[unknownParam,wlStr,flStr,modeStr]=getMatrixSumDTParamSettings(blkObj,pathItem)%#ok

    unknownParam=0;

    switch pathItem
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


