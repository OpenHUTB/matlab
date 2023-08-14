function results=getAllResultsForRun(this,runName)







    results=[];

    allDatasets=this.getAllDatasets;

    for i=1:length(allDatasets)
        dataset=allDatasets{i};
        results=[results,dataset.getRun(runName).getResults];%#ok<AGROW>
    end

end
