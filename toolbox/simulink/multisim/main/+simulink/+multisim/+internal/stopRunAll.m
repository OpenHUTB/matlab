function stopRunAll(modelHandle)




    dataId=simulink.multisim.internal.blockDiagramAssociatedDataId();
    bdData=Simulink.BlockDiagramAssociatedData.get(modelHandle,dataId);
    if isfield(bdData,"SimulationJob")&&bdData.SimulationJob.IsRunning
        bdData.SimulationJob.SimulationManager.cancel();
    end
    dig.postStringEvent('SimulinkEvent:Simulation');
end