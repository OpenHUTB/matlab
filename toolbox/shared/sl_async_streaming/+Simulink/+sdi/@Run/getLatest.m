function r=getLatest()




    r=Simulink.sdi.Run.empty;
    repo=sdi.Repository(1);
    Simulink.HMI.synchronouslyFlushWorkerQueue(repo);
    runIDs=repo.getAllRunIDs('SDIRun');
    if~isempty(runIDs)
        r=Simulink.sdi.Run(repo,runIDs(end));
    end
end
