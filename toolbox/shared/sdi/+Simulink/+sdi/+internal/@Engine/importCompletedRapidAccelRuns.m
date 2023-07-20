function importCompletedRapidAccelRuns(this,mdl)




    runIDs=this.sigRepository.importCompletedRapidAccelRuns(mdl);
    if~isempty(runIDs)
        runName=this.getRunName(runIDs(end));
        this.newRunIDs=runIDs;
        this.updateFlag=runName;
    end
end