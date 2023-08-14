function state_backup_RTWInfo(sigObjCache,openHandleIdx,blockObj)




    assert(~isempty(blockObj));

    RTWInfoBackup.StorageClass=blockObj.RTWStateStorageClass;
    RTWInfoBackup.TypeQualifier=blockObj.RTWStateStorageTypeQualifier;


    stateSignalObject=blockObj.StateSignalObject;
    if isempty(stateSignalObject)
        RTWInfoBackup.SignalObject=[];
    else
        RTWInfoBackup.SignalObject=stateSignalObject.copy;
    end


    RTWInfoBackup.StateSignalObjectClass=blockObj.StateSignalObjectClass;

    if isempty(openHandleIdx)
        sigObjCache.Editing{1}=[sigObjCache.Editing{1},blockObj.handle];
        sigObjCache.Editing{2}=[sigObjCache.Editing{2},RTWInfoBackup];
    else
        sigObjCache.Editing{2}(openHandleIdx)=RTWInfoBackup;
    end
