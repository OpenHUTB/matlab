function out=fetchOSLCProjectTypes(this,serverLoginInfoStruct,projectUri)

    server=serverLoginInfoStruct.server;
    rmServiceRootSuffix=rmi.settings_mgr('get','oslcSettings','rmRoot');
    username=serverLoginInfoStruct.username;
    passcode=serverLoginInfoStruct.passcode;




    out=this.repository.fetchProjectTypes(server,rmServiceRootSuffix,username,...
    slreq.data.ReqData.unconfuse(passcode,username),projectUri);
end