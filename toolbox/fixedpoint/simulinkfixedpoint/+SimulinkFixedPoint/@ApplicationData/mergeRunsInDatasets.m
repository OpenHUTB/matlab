function mergeRunsInDatasets(templateDataset,mergedDataset,RunName)








    templateRunObject=templateDataset.getRun(RunName);
    mergedRunObject=mergedDataset.getRun(RunName);
    SimulinkFixedPoint.ApplicationData.mergeResults(templateRunObject,mergedRunObject);

end
