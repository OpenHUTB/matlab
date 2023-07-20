function deleteRuns(this,mergedRunName,scenarioRunNames)





    allDatasets=fxptds.getAllDatasetsForModel(this.TopModel);

    for dIdx=1:numel(allDatasets)
        dataset=allDatasets{dIdx};
        dataset.deleteRun(mergedRunName);
        for sIdx=1:numel(scenarioRunNames)
            scenarioRunName=scenarioRunNames{sIdx};
            dataset.deleteRun(scenarioRunName);
        end
    end

end

