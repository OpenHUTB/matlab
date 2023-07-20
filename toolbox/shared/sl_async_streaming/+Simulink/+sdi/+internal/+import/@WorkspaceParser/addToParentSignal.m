function addToParentSignal(this,repo,varParsers,parentID)

    runID=repo.getSignalRunID(parentID);
    addToRun(this,repo,runID,varParsers,'',0,parentID);

    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    fw.onSignalAdded(runID);
end