function addZeroCrossingsBreakpointRF(cbinfo,action)




    breakpointType=slbreakpoints.datamodel.ModelBreakpointType.ZeroCrossing;
    action.enabled=SLStudio.toolstrip.internal.modelBreakpointRF(cbinfo,breakpointType);
end
