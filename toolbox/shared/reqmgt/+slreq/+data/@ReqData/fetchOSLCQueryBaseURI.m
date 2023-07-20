function out=fetchOSLCQueryBaseURI(this,serverLoginInfo,serviceUri)

    server=serverLoginInfo.server;
    rmServiceRootSuffix=rmi.settings_mgr('get','oslcSettings','rmRoot');
    username=serverLoginInfo.username;
    passcode=serverLoginInfo.passcode;




    out=this.repository.fetchQueryServiceURI(server,rmServiceRootSuffix,username,...
    slreq.data.ReqData.unconfuse(passcode,username),serviceUri);
end