function addSolverErrorBreakpointRF(cbinfo,action)




    breakpointType=slbreakpoints.datamodel.ModelBreakpointType.SolverError;
    action.enabled=SLStudio.toolstrip.internal.modelBreakpointRF(cbinfo,breakpointType);
end
