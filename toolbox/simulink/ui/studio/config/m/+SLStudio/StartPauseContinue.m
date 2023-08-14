function StartPauseContinue(model,modelHandle)




    if isequal(slfeature('slDebuggerSimStepperIntegration'),0)
        SLM3I.SLDomain.simulationStartPauseContinueFromHandleNAR(modelHandle);
        return;
    end

    isDebuggerActive=slInternal('sldebug',model,'IsDebuggerEnabled');
    bplistInstance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
    if isDebuggerActive


        if~bplistInstance.containsNoBPs()

            blockBreakpointsMap=bplistInstance.getBreakpoints.blockBreakpoints;
            keys=blockBreakpointsMap.keys;
            for key=keys
                bp=blockBreakpointsMap{key{1}};
                if bp.isEnabled
                    SLM3I.SLCommonDomain.simulationDebugStep(modelHandle,['break ',bp.blockPath]);
                end
            end
        end
        SLM3I.SLDomain.simulationStartPauseContinueFromHandleNAR(modelHandle);
    else



        if isequal(slfeature('sldebugConditionalBreakpoint'),1)||~bplistInstance.containsNoBPs()

            SLM3I.SLCommonDomain.simulationStartDebugging(modelHandle);
            if slfeature('slDebuggerShowOutputWindow')>0

                SimulinkDebugger.DebugSessionAccessor.getDebugSession(modelHandle);
            end
        else
            SLM3I.SLDomain.simulationStartPauseContinueFromHandleNAR(modelHandle);
        end
    end
end
