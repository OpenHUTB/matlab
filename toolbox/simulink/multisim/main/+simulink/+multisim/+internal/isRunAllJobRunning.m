function isJobRunning=isRunAllJobRunning(modelHandle)




    isJobRunning=false;
    dataId=simulink.multisim.internal.blockDiagramAssociatedDataId();
    if Simulink.BlockDiagramAssociatedData.isRegistered(modelHandle,dataId)
        bdData=Simulink.BlockDiagramAssociatedData.get(modelHandle,dataId);
        if isfield(bdData,"SimulationJob")&&bdData.SimulationJob.IsRunning
            isJobRunning=true;
        end
    end
end