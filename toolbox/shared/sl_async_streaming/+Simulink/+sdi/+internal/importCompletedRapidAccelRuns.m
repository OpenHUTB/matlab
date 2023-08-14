function importCompletedRapidAccelRuns(mdl,isMenuSim,varargin)




    repo=sdi.Repository(1);
    runIDs=repo.importCompletedRapidAccelRuns(mdl,varargin{:});
    Simulink.HMI.synchronouslyFlushWorkerQueue(repo);
    if~isempty(runIDs)
        fw=Simulink.sdi.internal.AppFramework.getSetFramework();
        fw.onRapidAccelRunImport(runIDs,mdl,isMenuSim);
    end
end