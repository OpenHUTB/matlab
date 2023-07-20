function updateRollupStatusLocally(this,dataObj)


    allViewers=this.getAllViewers;
    if isa(dataObj,'slreq.data.Requirement')
        if this.isImplementationStatusEnabled(allViewers)
            dataObj.updateImplementationStatus();
        end

        if this.isVerificationStatusEnabled(allViewers)
            dataObj.updateVerificationStatus();
        end
    end
end