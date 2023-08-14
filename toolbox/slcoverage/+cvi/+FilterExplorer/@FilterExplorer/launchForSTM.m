function filterExplorer=launchForSTM(ctxInfo)




    try
        ctxId=ctxInfo.filterCtxId;
        callbacks.startCallback=@(ctxId)stm.internal.Coverage.filterEditStartCallback(ctxId);
        callbacks.endCallback=@(ctxId,filterFiles)stm.internal.Coverage.filterEditEndCallback(ctxId,filterFiles);
        callbacks.filterChangedCallback=[];
        filterExplorer=cvi.FilterExplorer.FilterExplorer.create(ctxId,callbacks);
        filterExplorer.setCtx(ctxInfo);
    catch MEx
        rethrow(MEx);
    end
end
