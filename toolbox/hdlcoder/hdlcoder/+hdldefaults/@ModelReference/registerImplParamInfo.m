function registerImplParamInfo(this)




    baseRegisterImplParamInfo(this);


    this.addImplParamInfo('DSPStyle','ENUM','none',{'on','off','none'});
    this.addImplParamInfo('BalanceDelays','ENUM','inherit',{'inherit','on','off'});
    this.addImplParamInfo('DistributedPipelining','ENUM','inherit',{'inherit','on','off'});
    this.addImplParamInfo('StreamingFactor','POSINT',0);
    this.addImplParamInfo('SharingFactor','POSINT',0);
    this.addImplParamInfo('ReferenceModelPrefix','STRING','$bdroot');
end


