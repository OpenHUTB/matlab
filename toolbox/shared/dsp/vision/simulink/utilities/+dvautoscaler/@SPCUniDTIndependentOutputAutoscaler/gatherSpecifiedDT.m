function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(~,blkObj,~)





    specifiedDTStr=blkObj.OutDataTypeStr;
    comments={};
    paramNames.modeStr='OutDataTypeStr';
    paramNames.wlStr='';
    paramNames.flStr='';

    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

end




