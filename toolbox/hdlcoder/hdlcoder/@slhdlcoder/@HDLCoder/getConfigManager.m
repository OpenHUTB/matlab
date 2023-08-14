function configMgr=getConfigManager(this,mdlName)


    if nargin<2
        mdlName=this.ModelName;
    end

    try
        configMgr=this.ConfigManager(mdlName);
    catch
        configMgr=this.createConfigManager(mdlName);
    end
end
