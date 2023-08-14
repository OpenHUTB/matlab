


function frSigID=createFailureRegionSignal(verifySigID)

    sdiEngine=Simulink.sdi.Instance.engine;
    frSigID=sdiEngine.getMetaDataV2(verifySigID,'FailureRegionSigID');
    if~isempty(frSigID)&&sdiEngine.isValidSignalID(frSigID)
        return;
    end

    verifySig=Simulink.sdi.getSignal(verifySigID);
    [data,time]=stm.internal.verify.createFailureRegionSignalValues(verifySig.Values.Data,verifySig.Values.Time);
    verifyFRData=timeseries(data,time);

    verifyFRRunName=['verifyFRRun_',int2str(verifySig.RunID)];
    verifyFRRunID=0;

    stmRunIDs=Simulink.sdi.getAllRunIDs('stm');
    for idx=1:length(stmRunIDs)
        if(isequal(Simulink.sdi.getRun(stmRunIDs(idx)).Name,verifyFRRunName))
            verifyFRRunID=stmRunIDs(idx);
            break;
        end
    end

    if verifyFRRunID==0
        verifyFRRunID=Simulink.sdi.createRun(['verifyFRRun_',int2str(verifySig.RunID)]);
        Simulink.sdi.internal.moveRunToApp(verifyFRRunID,'stm');
    end

    frSigID=Simulink.sdi.addToRun(verifyFRRunID,'vars',verifyFRData);
    sdiEngine.setMetaDataV2(verifySigID,'FailureRegionSigID',frSigID);

end