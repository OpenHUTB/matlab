function bpEnabled=isModelBreakpointEnabled(breakpointType)




    bpListInstance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
    bps=bpListInstance.getBreakpoints();
    modelBps=bps.modelBreakpoints;

    editor=SLM3I.SLDomain.findLastActiveEditor();
    studio=editor.getStudio();
    topModel=get_param(studio.App.topLevelDiagram.handle,'Name');

    BPID=bpListInstance.createModelBPID(topModel,breakpointType);
    bpEnabled=~isempty(modelBps{BPID});
end

