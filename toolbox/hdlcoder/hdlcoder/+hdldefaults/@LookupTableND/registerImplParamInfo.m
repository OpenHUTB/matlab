function registerImplParamInfo(this)





    baseRegisterImplParamInfo(this);
    this.addImplParamInfo('MapToRAM','ENUM','inherit',{'inherit','on','off'});

    nfpInfo=registerNFPImplParamInfo(this,true,true);
    this.addImplParamInfo('PrecomputeCoefficients','ENUM','off',{'on','off'},nfpInfo);
    this.addImplParamInfo('AreaOptimization','ENUM','Parallel',{'Serial','Parallel'},nfpInfo);


