function registerImplParamInfo(this)





    baseRegisterImplParamInfo(this);

    this.addImplParamInfo('CoeffMultipliers','ENUM','multiplier',{'multiplier','csd','factored-csd'});
    this.addImplParamInfo('DALUTPartition','MxARRAY',-1);
    this.addImplParamInfo('DARadix','POSINT',2);
    this.addImplParamInfo('SerialPartition','MxARRAY',-1);
    this.addImplParamInfo('AddPipelineRegisters','ENUM','off',{'on','off'});
    this.addImplParamInfo('MultiplierInputPipeline','POSINT',0);
    this.addImplParamInfo('MultiplierOutputPipeline','POSINT',0);