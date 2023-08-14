function setSignalSourceType(this,sigIDs,val)
    validatestring(val,...
    {'logged','visualized','imported','comparison',...
    'tolerance','baseline','compare_to','difference'});
    for idx=1:length(sigIDs)
        this.sigRepository.setSignalSourceType(sigIDs(idx),val);
    end

    this.dirty=true;
end