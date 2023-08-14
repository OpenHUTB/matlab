function registerImplParamInfo(this)





    baseRegisterImplParamInfo(this);

    this.addImplParamInfo('ResetType','ENUM','default',{'default','none'});
    this.addImplParamInfo('DistributedPipelining','ENUM','off',{'on','off'});
    this.addImplParamInfo('MapPersistentVarsToRAM','ENUM','off',{'on','off'});
    this.addImplParamInfo('GuardIndexVariables','ENUM','off',{'on','off'});
    this.addImplParamInfo('ConstMultiplierOptimization','ENUM','none',{'csd','fcsd','auto','none'});
    this.addImplParamInfo('LoopOptimization','ENUM','none',{'none','Unrolling','Streaming'});
    this.addImplParamInfo('VariablesToPipeline','STRING','');
    this.addImplParamInfo('SharingFactor','POSINT',0);
