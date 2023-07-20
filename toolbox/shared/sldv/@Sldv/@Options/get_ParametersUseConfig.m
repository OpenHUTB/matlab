function prop=get_ParametersUseConfig(this,prop)




    if~this.checkslavtcchandle
        if isfield(this.PrivateData,'ParametersUseConfig')
            prop=this.PrivateData.ParametersUseConfig;
        end
    else
        prop=get_param(this.activeCS,[this.extproductTag,'ParametersUseConfig']);
    end
