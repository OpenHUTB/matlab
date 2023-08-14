
function[errMsg,errId]=getCovErrorMsg(analyzedModel,baseErrId)
    msgCatalog='stm:CoverageStrings:';
    if isempty(analyzedModel)
        errId=[msgCatalog,baseErrId];
        errMsg=message(errId);
    else
        errId=[msgCatalog,baseErrId,'WithModelName'];
        errMsg=message(errId,analyzedModel);
    end
end
