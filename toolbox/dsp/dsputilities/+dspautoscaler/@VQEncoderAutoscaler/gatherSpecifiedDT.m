function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)




    specifiedDTStr='';
    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

    comments={};
    signValStr='Signed';

    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';

    switch pathItem
    case 'Product output'
        unknownParam=false;
        modeStr='prodOutputMode';
        wlStr='prodOutputWordLength';
        flStr='prodOutputFracLength';

    case 'Accumulator'
        unknownParam=false;
        modeStr='accumMode';
        wlStr='accumWordLength';
        flStr='accumFracLength';



    otherwise
        unknownParam=true;
    end

    if unknownParam
        return;
    end

    paramNames.modeStr=modeStr;
    paramNames.wlStr=wlStr;
    paramNames.flStr=flStr;

    if h.isDataTypeFullyInherited(blkObj,pathItem)



        [~,~,~,specifiedDTStr]=h.getDataTypeInfoForPathItem(blkObj,pathItem);
        DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);
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
