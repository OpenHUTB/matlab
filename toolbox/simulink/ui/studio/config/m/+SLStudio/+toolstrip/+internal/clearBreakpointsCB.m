function clearBreakpointsCB(cbinfo)




    conditionalPauseList=SLStudio.toolstrip.internal.getConditionalPauseList(cbinfo.editorModel);
    bpListInstance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
    if isempty(conditionalPauseList)&&bpListInstance.containsNoBPs
        return;
    end

    function clearCondBps(port,conditionIdx)
        condStatus.index=port.data{conditionIdx,1};
        condStatus.status=3;
        set_param(port.portHandle,'ConditionalPauseStatus',condStatus);
    end

    if~isempty(conditionalPauseList)
        SLStudio.toolstrip.internal.loopConditionalBreakpoints(conditionalPauseList,@clearCondBps);
    end

    if~bpListInstance.containsNoBPs&&...
        slfeature('slDebuggerSimStepperIntegration')>0
        model=cbinfo.editorModel;
        if isempty(model),return;end
        bpListInstance.clearForModel(model.Name);
        bpListInstance.callRefresh();
    end

    if slfeature('slBreakpointList')>0
        bpListInstance.callRefresh();
    end
end
