function updateAllLeafSignals(topBusInfo,checkState)




    rows=BindMode.BindMode.getCurrentBindableRows;
    for indx=1:length(rows)
        if strcmp(rows(indx).bindableTypeChar,'BUSLEAFSIGNAL')&&...
            strcmp(rows(indx).bindableMetaData.parentId,topBusInfo.id)
            rows(indx).isConnected=checkState;
        end
    end
    bmRows=stm.internal.SignalLogging.getBindableRowsFromMetadata(rows);


    BindMode.BindMode.replaceBindableRows(bmRows);
end