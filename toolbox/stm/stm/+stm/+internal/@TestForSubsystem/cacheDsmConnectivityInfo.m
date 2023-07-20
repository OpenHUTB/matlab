function cacheDsmConnectivityInfo(obj,dStoreLoggingName,dsmBlkUserType,cutInd,dataStoreName)




    if dsmBlkUserType=="DataStoreRead"
        datasetType='inputs';
    else
        datasetType='outputs';
    end
    result=struct('ComponentIndex',cutInd,'DatasetType',datasetType,'DataStoreName',dataStoreName);
    keysOldValue=[];
    if obj.dataStoreLoggingInfo.isKey(dStoreLoggingName)
        keysOldValue=obj.dataStoreLoggingInfo(dStoreLoggingName);
    end
    obj.dataStoreLoggingInfo(dStoreLoggingName)=[keysOldValue,result];
end
