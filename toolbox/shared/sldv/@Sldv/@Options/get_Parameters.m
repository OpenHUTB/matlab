function prop=get_Parameters(this,prop)




    if~this.checkslavtcchandle
        if isfield(this.PrivateData,'Parameters')
            prop=this.PrivateData.Parameters;
        end
    else
        prop=get_param(this.activeCS,[this.extproductTag,'Parameters']);
    end
