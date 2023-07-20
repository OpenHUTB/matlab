function setSignalTmTimeRange(this,id,timeRange)
    timeRange=timeRange(:);
    validateattributes(timeRange(:),{'numeric'},{'size',[2,1]});
    this.sigRepository.setSignalTmTimeRange(id,double(timeRange));
end