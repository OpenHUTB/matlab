function mergeResultsOfRuns(dataset,templateRunName,mergedRunName)







    templateRunObject=dataset.getRun(templateRunName);
    mergedRunObject=dataset.getRun(mergedRunName);
    SimulinkFixedPoint.ApplicationData.mergeResults(templateRunObject,mergedRunObject);





    internalRun=dataset.getRun(fxptds.FPTDataset.MLFBInternalRunName);
    mergedRunObject.copyMLFBResults(internalRun);
    internalRun.removeAllResults();
end
