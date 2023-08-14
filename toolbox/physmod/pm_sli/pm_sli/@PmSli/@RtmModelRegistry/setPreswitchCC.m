function setPreswitchCC(this,mdl,platformCC)









    modelIdx=this.findModelEntry(mdl);
    howManyModels=length(modelIdx);

    switch howManyModels
    case 1

        this.modelInfo(modelIdx).modelData.preswitchCC=platformCC;

    case 0


    otherwise

        configData=RtmModelRegistry_config;
        pm_error(configData.Error.MultiplyRegisteredModel_templ_msgid,pmsl_sanitizename(mdl.Name));

    end




