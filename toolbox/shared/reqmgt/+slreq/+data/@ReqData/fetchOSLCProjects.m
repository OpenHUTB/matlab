function out=fetchOSLCProjects(this,serverLoginInfo)

    server=serverLoginInfo.server;
    rmServiceRootSuffix=rmi.settings_mgr('get','oslcSettings','rmRoot');
    username=serverLoginInfo.username;
    passcode=serverLoginInfo.passcode;




    out=this.repository.fetchProjects(server,rmServiceRootSuffix,username,...
    slreq.data.ReqData.unconfuse(passcode,username));
end