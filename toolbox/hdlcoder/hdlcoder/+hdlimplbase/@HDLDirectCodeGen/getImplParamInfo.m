function ipInfo=getImplParamInfo(this)






    if isempty(this.implParamInfo)
        registerImplParamInfo(this);
    end

    ipInfo=this.implParamInfo;
