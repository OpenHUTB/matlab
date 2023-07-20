function addZeroCrossingsBreakpointCB(cbinfo)




    breakpointType=slbreakpoints.datamodel.ModelBreakpointType.ZeroCrossing;
    SLStudio.toolstrip.internal.modelBreakpointCB(cbinfo,breakpointType);
end
