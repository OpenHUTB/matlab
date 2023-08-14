function[DTContInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)





    comments={};
    paramNames.modeStr='';
    paramNames.wlStr='';
    paramNames.flStr='';

    if strcmp(pathItem,'Table')
        DTContInfo=SimulinkFixedPoint.DTContainerInfo(...
        blkObj.Object.Table.DataType,blkObj.Context);
    else
        index=h.getIndexFromBreakpointPathitem(pathItem);
        DTContInfo=SimulinkFixedPoint.DTContainerInfo(...
        blkObj.Object.Breakpoints(index).DataType,blkObj.Context);
    end
end