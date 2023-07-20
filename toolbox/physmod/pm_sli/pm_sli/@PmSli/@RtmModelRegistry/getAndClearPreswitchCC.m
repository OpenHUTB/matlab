function platformCC=getAndClearPreswitchCC(this,mdl)









    modelIdx=this.findModelEntry(mdl);
    howManyModels=length(modelIdx);

    switch howManyModels
    case 1

        platformCC=this.modelInfo(modelIdx).modelData.preswitchCC;
        this.modelInfo(modelIdx).modelData.preswitchCC=[];







        if~isa(platformCC,'SSC.SimscapeCC')&&~isa(platformCC,'Simulink.ConfigSet')
            platformCC=[];
        end

    case 0

        platformCC=[];

    otherwise

        configData=RtmModelRegistry_config;
        pm_error(configData.Error.MultiplyRegisteredModel_templ_msgid,pmsl_sanitizename(mdl.Name));

    end




