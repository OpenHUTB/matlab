function updateOSLCRequirement(this,mfReq)

    mfReqSet=mfReq.requirementSet;
    server=mfReqSet.getProperty('serverName');
    username=oslc.user();
    passcode=oslc.passcode(username);
    if isempty(passcode)
        return;
    end
    rmServiceRootSuffix=rmi.settings_mgr('get','oslcSettings','rmRoot');


    this.repository.updateOSLCRequirement(mfReq,...
    server,rmServiceRootSuffix,username,slreq.data.ReqData.unconfuse(passcode,username));


    mfReq.synchronizedOn=slreq.utils.getDateTime(datetime(),'Write');




end
