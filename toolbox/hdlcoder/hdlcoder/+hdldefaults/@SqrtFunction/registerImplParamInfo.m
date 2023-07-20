function registerImplParamInfo(this)





    baseRegisterImplParamInfo(this);


    registerNFPImplParamInfo(this,true,false,false);





    this.addImplParamInfo('UseMultiplier','ENUM','off',{'on','off'});
    this.addImplParamInfo('UsePipelines','ENUM','on',{'on','off'});
    this.addImplParamInfo('LatencyStrategy','ENUM','inherit',{'inherit','Max','Min','Custom','Zero'});
    this.addImplParamInfo('CustomLatency','POSINT',0);
