function cb_ClearSDI(this,~,evt)



    appName=evt.app;
    if strcmp(evt.app,'AllSDI')
        appName='sdi';
    end

    if~strcmp(appName,this.AppName)
        return;
    end

    this.cacheSessionInfo('','',false);
end
