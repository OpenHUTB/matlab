function match=recompareSignals(compID,absTol,relTol,timeAlignMethod,interpMethod,fTol,bTol)

    engine=Simulink.sdi.Instance.engine;
    repo=sdi.Repository(1);
    baselineSigID=engine.getSignalComparisonResultByType(compID);

    engine.setSignalAbsTol(baselineSigID,absTol);
    engine.setSignalRelTol(baselineSigID,relTol);
    engine.setSignalInterpMethod(baselineSigID,interpMethod);
    engine.setSignalSyncMethod(baselineSigID,timeAlignMethod);
    repo.setSignalForwardTimeTol(baselineSigID,fTol);
    repo.setSignalBackwardTimeTol(baselineSigID,bTol);

    sigID=engine.getSignalSource(baselineSigID);

    if engine.isValidSignalID(sigID)

        engine.setSignalAbsTol(sigID,absTol);
        engine.setSignalRelTol(sigID,relTol);
        engine.setSignalInterpMethod(sigID,interpMethod);
        engine.setSignalSyncMethod(sigID,timeAlignMethod);
        repo.setSignalForwardTimeTol(sigID,fTol);
        repo.setSignalBackwardTimeTol(sigID,bTol);
    end


    engine.setSignalAbsTol(compID,absTol);
    engine.setSignalRelTol(compID,relTol);
    engine.setSignalInterpMethod(compID,interpMethod);
    engine.setSignalSyncMethod(compID,timeAlignMethod);
    repo.setSignalForwardTimeTol(compID,fTol);
    repo.setSignalBackwardTimeTol(compID,bTol);



    sglObj=engine.getSignalObject(compID);
    cmpRun=Simulink.sdi.getRun(sglObj.RunID);
    rnName=cmpRun.Name;
    cmpRun.Name='';
    ocp=onCleanup(@()cmpRun.set('Name',rnName));
    match=Simulink.sdi.recompareSignalsWithTolerance(...
    engine.sigRepository,compID,[]);
end
