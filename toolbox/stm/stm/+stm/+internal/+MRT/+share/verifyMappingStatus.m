


function[warnMessage,logOrError]=verifyMappingStatus(mappingStatus)
    warnMessage=[];
    switch mappingStatus
    case stm.internal.MappingStatus.NotMapped
        warnMessage=stm.internal.MRT.share.getString('stm:InputsView:InputsNotMappedLogMsg');
    case stm.internal.MappingStatus.Warnings
        warnMessage=stm.internal.MRT.share.getString('stm:InputsView:InputsWarningLogMsg');
    case stm.internal.MappingStatus.Failed
        warnMessage=stm.internal.MRT.share.getString('stm:InputsView:InputsFailedLogMsg');
    case stm.internal.MappingStatus.Stale
        warnMessage=stm.internal.MRT.share.getString('stm:InputsView:InputsStaleLogMsg');
    end

    logOrError=false(~isempty(warnMessage));
    assert(nnz(~isempty(warnMessage))==numel(logOrError));
end
