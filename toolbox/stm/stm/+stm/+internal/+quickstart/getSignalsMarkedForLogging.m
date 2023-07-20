function returnList=getSignalsMarkedForLogging(modelName,harnessName)



    [modelToUse,deactivateHarness,currHarness,oldHarness,~,wasHarnessOpen]=stm.internal.util.resolveHarness(modelName,harnessName);
    loggedDS=stm.internal.util.createLoggedSignalsDataset(modelToUse);


    if~isempty(currHarness)
        close_system(currHarness.name,0);

        if(deactivateHarness)
            stm.internal.util.loadHarness(oldHarness.ownerFullPath,oldHarness.name,wasHarnessOpen);
        end
    end


    var=struct('VarName','ds','VarValue',loggedDS);


    signalMetadata=stm.internal.util.getSigMetadata(var);

    returnList=getLoggedSignalsHelper(signalMetadata);
end

function lgSigList=getLoggedSignalsHelper(signalMetadata)

    nSigs=length(signalMetadata);
    lgSigList=repmat(struct('Name','',...
    'BlockPath','',...
    'PortIndex',''...
    ),nSigs,1);

    for idx=1:nSigs
        lgSigList(idx).Name=signalMetadata(idx).SignalLabel;
        lgSigList(idx).BlockPath=signalMetadata(idx).BlockPath;
        lgSigList(idx).PortIndex=signalMetadata(idx).PortIndex;
    end

end