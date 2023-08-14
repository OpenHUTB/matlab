function addSolverErrorBreakpointCB(cbinfo)




    breakpointType=slbreakpoints.datamodel.ModelBreakpointType.SolverError;
    SLStudio.toolstrip.internal.modelBreakpointCB(cbinfo,breakpointType);
end
