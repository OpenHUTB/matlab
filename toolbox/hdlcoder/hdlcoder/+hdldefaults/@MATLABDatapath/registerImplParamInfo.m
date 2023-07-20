function registerImplParamInfo(this)




    baseRegisterImplParamInfo(this);


    this.addImplParamInfo('FlattenHierarchy','ENUM','inherit',{'inherit','on','off'});
    this.addImplParamInfo('BalanceDelays','ENUM','inherit',{'inherit','on','off'});
    this.addImplParamInfo('DistributedPipelining','ENUM','inherit',{'inherit','on','off'});
    this.addImplParamInfo('StreamingFactor','POSINT',0);
    this.addImplParamInfo('SharingFactor','POSINT',0);
    this.addImplParamInfo('DSPStyle','ENUM','none',{'on','off','none'});
    this.addImplParamInfo('AdaptivePipelining','ENUM','inherit',{'inherit','on','off'});
    this.addImplParamInfo('ClockRatePipelining','ENUM','inherit',{'inherit','on','off'});


    this.addImplParamInfo('ConstMultiplierOptimization','ENUM','none',{'csd','fcsd','auto','none'});
    this.addImplParamInfo('InstantiateFunctions','ENUM','off',{'on','off'});
    this.addImplParamInfo('LoopOptimization','ENUM','Unrolling',{'Unrolling'});
    this.addImplParamInfo('MapPersistentVarsToRAM','ENUM','off',{'on','off'});
    this.addImplParamInfo('ResetType','ENUM','default',{'default','none'});
