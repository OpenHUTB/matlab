function enableDisableBreakpointsCB(cbinfo)




    conditionalPauseList=SLStudio.toolstrip.internal.getConditionalPauseList(cbinfo.editorModel);
    bpListInstance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
    if isempty(conditionalPauseList)&&bpListInstance.containsNoBPs
        return;
    end

    function setStatus(port,conditionIdx)
        conditionStatus=port.data{conditionIdx,4};

        if conditionStatus==0
            status=1;
        end
    end

    function toggleEnabled(port,conditionIdx)
        condStatus.index=port.data{conditionIdx,1};
        condStatus.status=status;
        set_param(port.portHandle,'ConditionalPauseStatus',condStatus);
    end

    if~isempty(conditionalPauseList)
        status=0;

        SLStudio.toolstrip.internal.loopConditionalBreakpoints(conditionalPauseList,@setStatus);
        if status==0
            status=bpListInstance.getBreakpointsStatusForModel();
        end
        SLStudio.toolstrip.internal.loopConditionalBreakpoints(conditionalPauseList,@toggleEnabled);
    else
        status=bpListInstance.getBreakpointsStatusForModel();
    end

    if~bpListInstance.containsNoBPs&&...
        slfeature('slDebuggerSimStepperIntegration')>0

        bpListInstance.enableDisableAllBreakpointsForModel(status);
    end

    if slfeature('slBreakpointList')>0

        bpListInstance.callRefresh();
    end
end
