function registerImplParamInfo(this)





    baseRegisterImplParamInfo(this);

    this.addImplParamInfo('ArchitectureSpecifiedBy','ENUM','NumMultipliers',{'NumMultipliers','FoldingFactor'});
    this.addImplParamInfo('FoldingFactor','POSINT',1);
    this.addImplParamInfo('NumMultipliers','POSINT',-1);