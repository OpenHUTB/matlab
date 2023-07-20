function SimulationForwardInDebuggerCB(modelName,modelHandle)





    isPausedInDebugLoop=slInternal('sldebug',modelName,'SldbgIsPausedInDebugLoop');
    if isPausedInDebugLoop
        SimulinkDebugger.utils.Stepper.forward(modelName)
        return;
    end

    bplistInstance=SimulinkDebugger.breakpoints.GlobalBreakpointsListAccessor.getInstance();
    if~bplistInstance.containsNoBPs()

        SLM3I.SLCommonDomain.simulationStartDebugging(modelHandle);
        if slfeature('slDebuggerShowOutputWindow')>0

            SimulinkDebugger.DebugSessionAccessor.getDebugSession(modelHandle);
        end
    else
        stepper=Simulink.SimulationStepper(modelName);
        stepper.forward();
    end
end


