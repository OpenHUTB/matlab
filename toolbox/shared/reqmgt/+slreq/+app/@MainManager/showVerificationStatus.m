function showVerificationStatus(this,cView)







    if~cView.displayVerificationStatus
        this.reqRoot.refreshVerificationStatus();
        cView.displayVerificationStatus=true;
    end
end
