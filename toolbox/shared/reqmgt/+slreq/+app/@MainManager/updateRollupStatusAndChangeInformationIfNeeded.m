function updated=updateRollupStatusAndChangeInformationIfNeeded(this,allViewers)









    updated=false;

    if nargin<2
        allViewers=this.getAllViewers;
    end

    isChangeEnabled=this.isChangeInformationEnabled(allViewers);
    isImplementationStatusEnabled=this.isImplementationStatusEnabled(allViewers);
    isVerificationStatusEnabled=this.isVerificationStatusEnabled(allViewers);


    if~(isChangeEnabled||isImplementationStatusEnabled||isVerificationStatusEnabled)
        return;
    end








    if isChangeEnabled


        ctmgr=this.changeTracker;
        if~isempty(ctmgr)
            ctmgr.refresh();
        end
        updated=true;
    end

    if isImplementationStatusEnabled

        this.reqRoot.refreshImplementationStatus();
        updated=true;
    end

    if isVerificationStatusEnabled

        resultsManager=slreq.data.ResultManager.getInstance();
        resultsManager.resetCache();
        this.reqRoot.refreshVerificationStatus();
        updated=true;
    end

end
