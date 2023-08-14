function out=addDSRToStruct(in,location)




    datasetVars=Simulink.SimulationData.DatasetRef.getDatasetVariableNames(location);
    n=numel(datasetVars);
    for idx=1:n
        in.(datasetVars{idx})=Simulink.SimulationData.DatasetRef(location,datasetVars{idx});
    end
    out=in;
end
