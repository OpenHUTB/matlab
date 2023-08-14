function baseBBoxRegisterImplParamInfo(this)





    baseRegisterImplParamInfo(this);

    this.addImplParamInfo('ClockInputPort','STRING','clk');
    this.addImplParamInfo('ClockEnableInputPort','STRING','clk_enable');
    this.addImplParamInfo('ResetInputPort','STRING','reset');
    this.addImplParamInfo('VHDLArchitectureName','STRING','rtl');
    this.addImplParamInfo('EntityName','STRING','');
    this.addImplParamInfo('VHDLComponentLibrary','STRING','work');
    this.addImplParamInfo('MultipleClockEnableInputPorts','MxARRAY',-1);


    this.addImplParamInfo('AddClockPort','ENUM','on',{'on','off'});
    this.addImplParamInfo('AddClockEnablePort','ENUM','on',{'on','off'});
    this.addImplParamInfo('AddResetPort','ENUM','on',{'on','off'});
    this.addImplParamInfo('InlineConfigurations','ENUM','on',{'on','off'});
    this.addImplParamInfo('ImplementationLatency','INT',-1);
    this.addImplParamInfo('AllowDistributedPipelining','ENUM','off',{'on','off'});
