function mergeModelReferenceData(modelObject,runName)








    appDataModelName=modelObject.getFullName;
    if isa(modelObject,'Simulink.SubSystem')||isa(modelObject,'Simulink.ModelReference')
        appDataModelName=bdroot(appDataModelName);
    end

    allDatasets=fxptds.getAllDatasetsForModel(appDataModelName);
    for datasetIndex=1:length(allDatasets)
        currentRunObj=allDatasets{datasetIndex}.getRun(runName);
        currentRunObj.deleteInvalidResults();
    end

    try
        SimulinkFixedPoint.ApplicationData.mergeResultsInReferenceModels(modelObject.getFullName,runName);
        SimulinkFixedPoint.Autoscaler.updateSpecifiedDataTypes(allDatasets,runName);
    catch fpt_exception %#ok<NASGU>
    end
end
