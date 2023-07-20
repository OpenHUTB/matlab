function registerImplParamInfo(this)




    baseRegisterImplParamInfo(this);

    this.addImplParamInfo('UsePipelinedKernel','ENUM','On',{'On','Off'});
    this.addImplParamInfo('LatencyStrategy','ENUM','MAX',{'MAX','CUSTOM','ZERO'});
    this.addImplParamInfo('CustomLatency','POSINT',0);
end
