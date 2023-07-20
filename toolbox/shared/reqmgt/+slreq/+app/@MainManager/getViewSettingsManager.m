function vsmgr=getViewSettingsManager(this)








    if isempty(this.viewSettingsManager)

        this.viewSettingsManager=slreq.app.ViewSettingsManager();
    end

    vsmgr=this.viewSettingsManager;
end
