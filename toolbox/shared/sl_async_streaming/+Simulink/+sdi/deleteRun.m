function deleteRun(runID)






    try

        repo=sdi.Repository(1);
        Simulink.HMI.synchronouslyFlushWorkerQueue(repo);


        fw=Simulink.sdi.internal.AppFramework.getSetFramework();
        fw.deleteRun(runID)
    catch me
        throwAsCaller(me);
    end
end
