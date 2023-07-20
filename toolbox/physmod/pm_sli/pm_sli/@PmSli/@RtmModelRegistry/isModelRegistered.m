function isRegistered=isModelRegistered(this,mdl)




    whichEntry=this.findModelEntry(mdl);

    switch length(whichEntry)
    case 0
        isRegistered=false;
    case 1
        isRegistered=this.modelInfo(whichEntry).modelData.registered;
    otherwise
        configData=RtmModelRegistry_config;
        pm_error(configData.Error.MultiplyRegisteredModel_templ_msgid,mdl.Name);
    end



