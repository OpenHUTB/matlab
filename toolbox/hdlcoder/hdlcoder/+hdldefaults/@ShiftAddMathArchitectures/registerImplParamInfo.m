function registerImplParamInfo(this)



    baseRegisterImplParamInfo(this);

    this.addImplParamInfo('UsePipelines','ENUM','on',{'on','off'});
    this.addImplParamInfo('LatencyStrategy','ENUM','MAX',{'MAX','CUSTOM','ZERO'});
    this.addImplParamInfo('CustomLatency','POSINT',0);
end
