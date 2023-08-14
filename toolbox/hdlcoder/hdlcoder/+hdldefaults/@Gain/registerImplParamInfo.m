function registerImplParamInfo(this)





    baseRegisterImplParamInfo(this);


    this.addImplParamInfo('ConstMultiplierOptimization','ENUM','none',{'csd','fcsd','auto','none'});
    this.addImplParamInfo('DSPStyle','ENUM','none',{'on','off','none'});



    registerNFPImplParamInfo(this,true,true,true);
