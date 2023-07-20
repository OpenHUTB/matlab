function ret=getRootComparisonSignalID(this,sigID)








    ret=0;
    if~this.isValidSignalID(sigID)
        return
    end


    st=this.getSignalSourceType(sigID);
    switch st
    case 'comparison'
        ret=sigID;

    case{'tolerance','baseline','compare_to','difference'}
        ret=this.getSignalParent(sigID);

    otherwise
        sigID=this.sigRepository.findCopiedCompareSignal(sigID);
        ret=this.getRootComparisonSignalID(sigID);
    end
end
