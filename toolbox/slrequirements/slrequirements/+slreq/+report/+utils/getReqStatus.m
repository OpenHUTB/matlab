function status=getReqStatus(req,statustype,refresh)



    switch lower(statustype)
    case 'implementationstatus'
        if refresh
            req.updateImplementationStatus;
        end
        status=req.getImplementationStatus();
    case 'verificationstatus'
        if refresh
            req.updateVerificationStatus;
        end
        status=req.getVerificationStatus();
    end
end

