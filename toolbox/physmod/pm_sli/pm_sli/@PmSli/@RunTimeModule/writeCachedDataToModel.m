function writeCachedDataToModel(this,mdl)







    [topologyChecksum,parameterChecksum]=this.getCachedModelChecksum(mdl);
    products=this.getModelProducts(mdl);

    configData=RunTimeModule_config;
    errorData=configData.Error;



    try
        add_param(mdl.Handle,configData.ModelTopologyChecksum.PropertyName,num2str(topologyChecksum));
    catch exception
        if strcmp(exception.identifier,configData.AddParamErrorId)
            set_param(mdl.Handle,configData.ModelTopologyChecksum.PropertyName,num2str(topologyChecksum));
        else
            pm_error(errorData.CannotSetParamProperty_templ_msgid,...
            configData.ModelTopologyChecksum.PropertyName,...
            exception.message);
        end
    end




    try
        add_param(mdl.Handle,configData.ModelParameterChecksum.PropertyName,num2str(parameterChecksum));
    catch exception
        if strcmp(exception.identifier,configData.AddParamErrorId)
            set_param(mdl.Handle,configData.ModelParameterChecksum.PropertyName,num2str(parameterChecksum));
        else
            pm_error(errorData.CannotSetParamProperty_templ_msgid,...
            cconfigData.ModelParameterChecksum.PropertyName,...
            exception.message);
        end
    end




    productString=products{1};
    for idx=2:numel(products)
        productString=sprintf('%s|%s',productString,products{idx});
    end
    try
        add_param(mdl.Handle,configData.ProductsUsed.PropertyName,productString);
    catch exception
        if strcmp(exception.identifier,configData.AddParamErrorId)
            set_param(mdl.Handle,configData.ProductsUsed.PropertyName,productString);
        else
            pm_error(errorData.CannotSetParamProperty_templ_msgid,...
            configData.ProductsUsed.PropertyName,...
            exception.message);
        end
    end



