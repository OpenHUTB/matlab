function registerImplParamInfo(this)





    baseRegisterImplParamInfo(this);


    this.addImplParamInfo('ConstMultiplierOptimization','ENUM','none',{'csd','fcsd','auto','none'});
    this.addImplParamInfo('DSPStyle','ENUM','none',{'on','off','none'});
    this.addImplParamInfo('DotProductStrategy','ENUM','Fully Parallel',...
    {'Fully Parallel','Fully Parallel Scalarized','Serial Multiply-Accumulate','Parallel Multiply-Accumulate'});




    registerNFPImplParamInfo(this,true,true,true);
