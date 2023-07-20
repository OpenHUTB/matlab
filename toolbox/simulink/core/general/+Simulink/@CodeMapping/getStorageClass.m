function storageClass=getStorageClass(sourceModel,sigName)




    storageClass='';
    if existsInGlobalScope(sourceModel,sigName)
        slObj=evalinGlobalScope(sourceModel,sigName);
        if isa(slObj,'Simulink.Signal')
            storageClass=slObj.StorageClass;
        end
    end
end
