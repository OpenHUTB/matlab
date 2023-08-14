function prop=set_DetectBlockConditions(this,prop)




    if~this.checkslavtcchandle

        if isfield(this.PrivateData,'DetectBlockConditions')
            this.PrivateData.DetectBlockConditions=prop;
        end
    else

        set_param(this.sldvcc.getParent,[this.extproductTag,'DetectBlockConditions'],prop);
    end
