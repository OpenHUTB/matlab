function deleteSignal(signalID)




    try

        repo=sdi.Repository(1);
        Simulink.HMI.synchronouslyFlushWorkerQueue(repo);


        fw=Simulink.sdi.internal.AppFramework.getSetFramework();
        fw.deleteSignal(signalID)
    catch me
        throwAsCaller(me);
    end
end