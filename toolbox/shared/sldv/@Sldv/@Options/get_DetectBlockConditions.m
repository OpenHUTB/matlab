function prop=get_DetectBlockConditions(this,prop)




    if~this.checkslavtcchandle

        if isfield(this.PrivateData,'DetectBlockConditions')
            prop=this.PrivateData.DetectBlockConditions;
        end
        if isfield(this.PrivateData,'DetectHISMViolationsHisl_0002')&&...
            strcmp(this.PrivateData.DetectHISMViolationsHisl_0002,'on')
            prop=[prop,' HISL_0002'];
        end
        if isfield(this.PrivateData,'DetectHISMViolationsHisl_0003')&&...
            strcmp(this.PrivateData.DetectHISMViolationsHisl_0003,'on')
            prop=[prop,' HISL_0003'];
        end
        if isfield(this.PrivateData,'DetectHISMViolationsHisl_0004')&&...
            strcmp(this.PrivateData.DetectHISMViolationsHisl_0004,'on')
            prop=[prop,' HISL_0004'];
        end
        if isfield(this.PrivateData,'DetectHISMViolationsHisl_0028')&&...
            strcmp(this.PrivateData.DetectHISMViolationsHisl_0028,'on')
            prop=[prop,' HISL_0028'];
        end
    else

        prop=get_param(this.sldvcc.getParent,[this.extproductTag,'DetectBlockConditions']);
        if strcmp(get_param(this.sldvcc.getParent,...
            [this.extproductTag,'DetectHISMViolationsHisl_0002']),'on')
            prop=[prop,' HISL_0002'];
        end
        if strcmp(get_param(this.sldvcc.getParent,...
            [this.extproductTag,'DetectHISMViolationsHisl_0003']),'on')
            prop=[prop,' HISL_0003'];
        end
        if strcmp(get_param(this.sldvcc.getParent,...
            [this.extproductTag,'DetectHISMViolationsHisl_0004']),'on')
            prop=[prop,' HISL_0004'];
        end
        if strcmp(get_param(this.sldvcc.getParent,...
            [this.extproductTag,'DetectHISMViolationsHisl_0028']),'on')
            prop=[prop,' HISL_0028'];
        end
    end
