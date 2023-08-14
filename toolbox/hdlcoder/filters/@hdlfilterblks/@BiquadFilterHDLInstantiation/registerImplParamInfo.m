function registerImplParamInfo(this)





    baseRegisterImplParamInfo(this);

    this.addImplParamInfo('CoeffMultipliers','ENUM','multiplier',{'multiplier','csd','factored-csd'});
    this.addImplParamInfo('AddPipelineRegisters','ENUM','off',{'on','off'});