function addNanValuesBreakpointRF(cbinfo,action)




    breakpointType=slbreakpoints.datamodel.ModelBreakpointType.NanValues;
    action.enabled=SLStudio.toolstrip.internal.modelBreakpointRF(cbinfo,breakpointType);
end
