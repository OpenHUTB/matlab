function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(~,blkObj,~)




    comments={};

    specifiedDTStr=blkObj.OutDataTypeStr;
    paramNames.modeStr='OutDataTypeStr';

    paramNames.wlStr='';
    paramNames.flStr='';

    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);
end



