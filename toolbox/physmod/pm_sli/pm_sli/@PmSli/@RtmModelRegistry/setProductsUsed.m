function setProductsUsed(this,mdl,productList)







    modelIdx=this.findModelEntry(mdl);
    howManyModels=length(modelIdx);

    switch howManyModels
    case 1

        this.modelInfo(modelIdx).modelData.productsUsed=productList;

    case 0

        configData=RtmModelRegistry_config;
        pm_error(configData.Error.ModelNotRegistered_templ_msgid,pmsl_sanitizename(mdl.Name));

    otherwise

        configData=RtmModelRegistry_config;
        pm_error(configData.Error.MultiplyRegisteredModel_templ_msgid,pmsl_sanitizename(mdl.Name));

    end




