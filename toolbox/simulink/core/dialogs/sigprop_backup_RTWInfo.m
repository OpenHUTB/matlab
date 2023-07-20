function sigprop_backup_RTWInfo(sigObjCache,openHandleIdx,portObj)




    assert(~isempty(portObj));

    sourceBlock=portObj.Parent;
    sourceModel=bdroot(sourceBlock);

    RTWInfoBackup=Simulink.CodeMapping.backup(sourceModel,sourceBlock);
    RTWInfoBackup.StorageClass=portObj.RTWStorageClass;
    RTWInfoBackup.TypeQualifier=portObj.RTWStorageTypeQualifier;



    portSignalObject=portObj.SignalObject;
    if isempty(portSignalObject)
        RTWInfoBackup.SignalObject=[];
    else
        RTWInfoBackup.SignalObject=portSignalObject.copy;
    end


    RTWInfoBackup.SignalObjectClass=portObj.SignalObjectClass;

    if isempty(openHandleIdx)
        sigObjCache.Editing{1}=[sigObjCache.Editing{1},portObj.handle];
        sigObjCache.Editing{2}=[sigObjCache.Editing{2},RTWInfoBackup];
    else
        sigObjCache.Editing{2}(openHandleIdx)=RTWInfoBackup;
    end
