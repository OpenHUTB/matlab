function isLogsData=is_logs_data(blkType)





    isLogsData=false;
    blkInfoMap=simmechanics.sli.internal.getTypeIdBlockInfoMap;
    if(blkInfoMap.isKey(blkType))
        blkInfo=blkInfoMap(blkType);
        isLogsData=blkInfo.LogsData;
    end

end
