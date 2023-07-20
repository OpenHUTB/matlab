function registerImplParamInfo(this)




    baseRegisterImplParamInfo(this);


    this.addImplParamInfo('FlattenHierarchy','ENUM','inherit',{'inherit','on','off'});
    this.addImplParamInfo('BalanceDelays','ENUM','inherit',{'inherit','on','off'});
    this.addImplParamInfo('DistributedPipelining','ENUM','inherit',{'inherit','on','off'});
    this.addImplParamInfo('SharingFactor','POSINT',0);
    this.addImplParamInfo('ClockRatePipelining','ENUM','inherit',{'inherit','on','off'});
