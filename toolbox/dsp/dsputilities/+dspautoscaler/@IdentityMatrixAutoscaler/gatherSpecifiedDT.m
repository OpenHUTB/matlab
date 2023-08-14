function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(~,blkObj,~)



    comments={};
    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';

    if strcmpi(blkObj.Inherit,'on')

        specifiedDTStr='Inherit: Same as input';

    else

        specifiedDTStr=blkObj.OutDataTypeStr;
        paramNames.modeStr='OutDataTypeStr';

    end

    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

end



