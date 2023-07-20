function addStepSizeBreakpointCB(cbinfo)




    breakpointType=slbreakpoints.datamodel.ModelBreakpointType.StepSizeLimited;
    SLStudio.toolstrip.internal.modelBreakpointCB(cbinfo,breakpointType);
end
