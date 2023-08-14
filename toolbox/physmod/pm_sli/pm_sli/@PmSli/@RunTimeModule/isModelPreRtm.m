function isPreRtm=isModelPreRtm(this,mdl)




    modelIdx=this.modelRegistry.findModelEntry(mdl);
    howManyModels=length(modelIdx);

    switch howManyModels
    case 1

        isPreRtm=this.modelRegistry.modelInfo(modelIdx).modelData.isModelPreRtm;

    case 0

        configData=RtmModelRegistry_config;
        pm_error(configData.Error.ModelNotRegistered_templ_msgid,pmsl_sanitizename(mdl.Name));

    otherwise

        configData=RtmModelRegistry_config;
        pm_error(configData.Error.MultiplyRegisteredModel_templ_msgid,pmsl_sanitizename(mdl.Name));

    end

end




