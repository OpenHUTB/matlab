function[DTContInfo,comments,paramNames]=gatherSpecifiedDT(~,blkObj,~)





    comments={};
    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';

    DTContInfo=SimulinkFixedPoint.DTContainerInfo(...
    blkObj.Object.Breakpoints.DataType,blkObj.Context);
end