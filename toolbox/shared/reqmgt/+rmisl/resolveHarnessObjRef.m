function[harnessName,harnessId,localSid]=resolveHarnessObjRef(modelH,storedId,doOpen)
    [harnessId,localSid]=rmisl.harnessTargetIdToSID(storedId);

    if doOpen
        harnesses=Simulink.harness.find(modelH);
        for i=1:length(harnesses)
            if strcmp(harnesses(i).uuid,harnessId)
                harnessName=harnesses(i).name;
                ownerPath=harnesses(i).ownerFullPath;
                Simulink.harness.open(ownerPath,harnessName,'CreateOpenContext',true,'ReuseWindow',true);
                return;
            end
        end
    else
        activeHarness=Simulink.harness.internal.getActiveHarness(modelH);
        if~isempty(activeHarness)&&strcmp(activeHarness.uuid,harnessId)
            harnessName=activeHarness.name;
            return;
        end
    end

    harnessName='';
end
