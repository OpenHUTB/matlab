







function deleteSpecificHarnesses(modelHandle,exportToVersion)
    harnessList=Simulink.harness.find(modelHandle);

    if~isempty(harnessList)
        if(exportToVersion=="R2014bOrEarlier")
            Simulink.harness.internal.deleteAllHarnesses(modelHandle);
        elseif(exportToVersion=="R2016bOrEarlier")
            updateExplicitSyncFlag(harnessList);
            deleteHarnessesForUDFAndImplicitLinks(harnessList);
        elseif(exportToVersion=="R2019b")


            deleteHarnessesForSSRef(modelHandle,harnessList);
        end
    end
end


function deleteHarnessesForUDFAndImplicitLinks(harnessList)
    for i=1:numel(harnessList)
        currHarness=harnessList(i);

        if Simulink.harness.internal.isImplicitLink(currHarness.ownerHandle)||...
            Simulink.harness.internal.isUserDefinedFcnBlock(currHarness.ownerHandle)

            Simulink.harness.internal.deleteHarness(currHarness.model,currHarness.name,currHarness.ownerHandle);
        end
    end
end


function updateExplicitSyncFlag(harnessList)
    for i=1:numel(harnessList)
        currHarness=harnessList(i);
        if currHarness.synchronizationMode==2&&currHarness.verificationMode==0
            if strcmp(currHarness.ownerType,'Simulink.BlockDiagram')
                Simulink.harness.set(currHarness.ownerHandle,currHarness.name,'SynchronizationMode','SyncOnOpen');
            else
                Simulink.harness.set(currHarness.ownerHandle,currHarness.name,'SynchronizationMode','SyncOnOpenAndClose');
            end

        end
    end
end


function deleteHarnessesForSSRef(modelHandle,harnessList)
    if(bdIsSubsystem(modelHandle))




        set_param(modelHandle,'Open','on')
        Simulink.harness.internal.deleteAllHarnesses(modelHandle);
    else


        for hCtr=1:numel(harnessList)
            currHarness=harnessList(hCtr);
            isSSReferenceBlockOwner=currHarness.ownerType=="Simulink.SubSystem"&&...
            ~isempty(get_param(currHarness.ownerHandle,'ReferencedSubsystem'));
            if isSSReferenceBlockOwner
                Simulink.harness.internal.deleteHarness(currHarness.model,currHarness.name,currHarness.ownerHandle);
            end

        end
    end
end
