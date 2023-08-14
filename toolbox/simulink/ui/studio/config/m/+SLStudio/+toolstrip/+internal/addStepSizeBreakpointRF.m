function addStepSizeBreakpointRF(cbinfo,action)




    breakpointType=slbreakpoints.datamodel.ModelBreakpointType.StepSizeLimited;
    action.enabled=SLStudio.toolstrip.internal.modelBreakpointRF(cbinfo,breakpointType);
end
