function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,~)




    dtContainerStr=blkObj.DataType;
    comments={};
    paramNames.modeStr='DataType';
    paramNames.wlStr='';
    paramNames.flStr='';
    DTConInfo=SimulinkFixedPoint.DTContainerInfo(dtContainerStr,blkObj);

end

