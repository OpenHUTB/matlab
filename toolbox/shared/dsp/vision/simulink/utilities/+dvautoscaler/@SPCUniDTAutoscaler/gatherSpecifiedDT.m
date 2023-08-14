function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)






    paramNames.wlStr='';
    paramNames.flStr='';
    [specifiedDTStr,modeStr]=getSpecifiedSPCUniDTString(h,blkObj,pathItem);
    paramNames.modeStr=modeStr;

    comments={};

    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);

end




