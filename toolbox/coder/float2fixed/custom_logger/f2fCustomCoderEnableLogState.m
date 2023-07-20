function out=f2fCustomCoderEnableLogState(vals)
    mlock;
    persistent pVals
    if isempty(pVals)
        pVals=coder.internal.LoggerService.CUSTOM_LOG_ENABLE_LOG_DEFAULT;
    end
    if nargin==1
        pVals=vals;
    end
    out=pVals;
end