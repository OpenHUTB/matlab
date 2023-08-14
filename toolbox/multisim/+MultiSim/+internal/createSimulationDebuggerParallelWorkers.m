






function debugger=createSimulationDebuggerParallelWorkers(modelName,dq)
    load_system(modelName);
    h=get_param(modelName,'Handle');
    dataId='SL_SimulationDebuggerParallelWorker';
    callbackId=[dataId,'_CB'];
    if~Simulink.BlockDiagramAssociatedData.isRegistered(h,dataId)
        Simulink.BlockDiagramAssociatedData.register(h,dataId,'any');
    end

    debugger=Simulink.BlockDiagramAssociatedData.get(h,dataId);
    if isempty(debugger)||~isvalid(debugger)


        debugger=MultiSim.internal.SimulationDebuggerParallelWorker(modelName,dq);
        Simulink.BlockDiagramAssociatedData.set(h,dataId,debugger);
        Simulink.addBlockDiagramCallback(h,'PreClose',callbackId,@()delete(debugger));
    end
end