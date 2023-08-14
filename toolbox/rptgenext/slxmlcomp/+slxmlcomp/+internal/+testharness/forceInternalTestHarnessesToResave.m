function forceInternalTestHarnessesToResave(modelName)







    if strcmp(get_param(modelName,'Lock'),'on')
        Simulink.harness.internal.setBDLock(modelName,false);
        lockCleanup=onCleanup(@()Simulink.harness.internal.setBDLock(modelName,true));
    end

    harnessList=Simulink.harness.internal.getHarnessList(modelName);

    for ii=1:numel(harnessList)
        harness=harnessList(ii);

        if(harness.saveExternally)
            continue
        end



        origVal=slsvTestingHook('IgnoreOwnerTypeCheckDuringClone',1);
        hookCleanup=onCleanup(@()slsvTestingHook('IgnoreOwnerTypeCheckDuringClone',origVal));




        syncCleanup=preventHarnessSync(harness);

        Simulink.harness.internal.load(harness.ownerFullPath,harness.name,false);
        set_param(harness.name,'Dirty','on')
        close_system(harness.name);
        delete(syncCleanup);
        delete(hookCleanup)
    end

end

function cleanup=preventHarnessSync(harness)
    synchronizationModes={'SyncOnOpenAndClose','SyncOnOpen','SyncOnPushRebuildOnly'};
    prevSyncMode=synchronizationModes{harness.synchronizationMode+1};

    ownerHandle=get_param(harness.ownerFullPath,'handle');
    cleanup=onCleanup(@()Simulink.harness.set(...
    ownerHandle,harness.name,'SynchronizationMode',prevSyncMode...
    ));
    Simulink.harness.set(...
    ownerHandle,...
    harness.name,...
    'SynchronizationMode','SyncOnOpen'...
    );

end