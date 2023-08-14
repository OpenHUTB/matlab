function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)






    paramNames.wlStr='';
    paramNames.flStr='';
    [specifiedDTStr,paramNames.modeStr]=getSpecifiedSPCUniDTString(h,blkObj,pathItem);
    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);
    comments={};
end