function registerImplParamInfo(this)


    this.addImplParamInfo('InputPipeline','POSINT',0);
    this.addImplParamInfo('OutputPipeline','POSINT',0);
    this.addImplParamInfo('ResetType','ENUM','default',{'default','none'});
    this.addImplParamInfo('SoftReset','ENUM','off',{'on','off'});
end
