function[DTConInfo,comments,paramNames]=gatherSpecifiedDT(~,blkObj,~)




    specifiedDTStr='';
    comments={};
    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';

    DTConInfo=SimulinkFixedPoint.DTContainerInfo(specifiedDTStr,blkObj);


