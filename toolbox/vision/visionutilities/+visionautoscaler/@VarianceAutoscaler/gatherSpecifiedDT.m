function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)




    specifiedDTStr='';
    comments={};
    unknownParam=0;
    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';

    switch pathItem
    case 'Input-squared product'
        wlStr='prodOutputWordLength';
        flStr='prodOutputFracLength';
    case 'Input-sum-squared product'
        wlStr='memoryWordLength';
        flStr='memoryFracLength';
    case 'Accumulator'
        wlStr='accumWordLength';
        flStr='accumFracLength';
    case 'Output'
        wlStr='outputWordLength';
        flStr='outputFracLength';
    otherwise
        unknownParam=1;
        wlStr='';
        flStr='';
    end

    if~unknownParam

        endIdx=regexp(wlStr,'WordLength$')-1;
        prefixStr=wlStr(1:endIdx);
        modeStr=strcat(prefixStr,'Mode');

        paramNames.wlStr=wlStr;
        paramNames.flStr=flStr;
        paramNames.modeStr=modeStr;

        if h.isDataTypeFullyInherited(blkObj,pathItem)



            [~,~,~,specifiedDTStr,flStr,modeStr,wlStr]=h.getDataTypeInfoForPathItem(blkObj,pathItem);
            paramNames.wlStr=wlStr;
            paramNames.flStr=flStr;
            paramNames.modeStr=modeStr;
        else


            signValStr=h.getInportSignednessString(blkObj);


            wlString=paramNames.wlStr;
            wlValueStr=blkObj.(wlString);


            if~isempty(wlValueStr)

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




