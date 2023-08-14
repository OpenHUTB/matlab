





function out=createSimulationOutput(ME,modelName)
    try
        metadataWrapper=Simulink.SimMetadataWrapper(modelName);
        metaStruct=metadataWrapper.matlabStruct(1);
    catch


        metaStruct=struct("ModelInfo",[],"TimingInfo",[],"ExecutionInfo",[]);
    end
    metaStruct.ExecutionInfo.StopEvent='DiagnosticError';
    metaStruct.ExecutionInfo.StopEventDescription=ME.message;
    metaStruct.ExecutionInfo.ErrorDiagnostic=...
    struct('Diagnostic',MSLDiagnostic(ME));
    out=Simulink.SimulationOutput(struct,metaStruct);
end