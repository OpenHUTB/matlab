function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)




    comments={};
    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';

    validPathItems=h.getPathItems(blkObj);

    specifiedDTStr='';
    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

    if~ismember(pathItem,validPathItems)
        return;
    end

    if h.isDataTypeFullyInherited(blkObj,pathItem)



        [~,~,~,specifiedDTStr,flStr,modeStr,wlStr]=h.getDataTypeInfoForPathItem(blkObj,pathItem);

        paramNames.wlStr=wlStr;
        paramNames.flStr=flStr;
        paramNames.modeStr=modeStr;
    elseif h.isDataTypeFracLengthOnlyInherited(blkObj,pathItem)

        [signValStr,wlValueStr,~,~,flStr,modeStr,wlStr]=h.getDataTypeInfoForPathItem(blkObj,pathItem);
        specifiedDTStr=h.getUDTStrFromFixPtInfo(blkObj,signValStr,wlValueStr);

        paramNames.wlStr=wlStr;
        paramNames.flStr=flStr;
        paramNames.modeStr=modeStr;
    else

        [signValStr,wlValueStr,flValueStr,specifiedDTStr,...
        flStr,modeStr,wlStr]=h.getDataTypeInfoForPathItem(blkObj,pathItem);
        paramNames.wlStr=wlStr;
        paramNames.flStr=flStr;
        paramNames.modeStr=modeStr;
        if isempty(wlValueStr)||isempty(flValueStr)
            DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);
            return;
        else
            specifiedDTStr=h.getUDTStrFromFixPtInfo(blkObj,signValStr,wlValueStr,flValueStr);
        end
    end

    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

end




