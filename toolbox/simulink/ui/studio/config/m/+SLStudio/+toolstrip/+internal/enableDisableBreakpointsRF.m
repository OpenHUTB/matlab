function enableDisableBreakpointsRF(cbinfo,action)




    action.enabled=false;

    conditionalPauseList=SLStudio.toolstrip.internal.getConditionalPauseList(cbinfo.editorModel);

    bpListInstance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
    if~isempty(conditionalPauseList)||~bpListInstance.containsNoBPs
        action.enabled=true;
    end
end
