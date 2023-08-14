function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(~,blkObj,~)




    comments={};

    if strcmp(blkObj.CBsource,'Specify via dialog')

        specifiedDTStr=blkObj.OutDataTypeStr;
        paramNames.modeStr='OutDataTypeStr';
    else

        specifiedDTStr='Inherit: Same as input';
        paramNames.modeStr='';
    end

    paramNames.wlStr='';
    paramNames.flStr='';

    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);
end



