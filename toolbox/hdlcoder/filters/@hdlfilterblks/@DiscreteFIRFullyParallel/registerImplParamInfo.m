function registerImplParamInfo(this)





    baseRegisterImplParamInfo(this);

    this.addImplParamInfo('CoeffMultipliers','ENUM','multiplier',{'multiplier','csd','factored-csd'});
    this.addImplParamInfo('AddPipelineRegisters','ENUM','off',{'on','off'});
    this.addImplParamInfo('MultiplierInputPipeline','POSINT',0);
    this.addImplParamInfo('MultiplierOutputPipeline','POSINT',0);
    this.addImplParamInfo('ChannelSharing','ENUM','off',{'on','off'});