function configMgr=createConfigManager(this,mdlName)



    if nargin<2
        mdlName=this.ModelName;
    end

    if this.ConfigManager.isKey(mdlName)

        configMgr=this.ConfigManager(mdlName);
    else

        db=this.getImplDatabase;
        configMgr=slhdlcoder.ConfigurationManager(mdlName,db);
        this.ConfigManager(mdlName)=configMgr;
    end
end
