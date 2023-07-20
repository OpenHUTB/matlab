function prop=get_ParameterConfiguration(this,prop)




    if~this.checkslavtcchandle
        if isfield(this.PrivateData,'ParameterConfiguration')
            prop=this.PrivateData.ParameterConfiguration;
        end
    else
        prop=get_param(this.activeCS,[this.extproductTag,'ParameterConfiguration']);
    end
