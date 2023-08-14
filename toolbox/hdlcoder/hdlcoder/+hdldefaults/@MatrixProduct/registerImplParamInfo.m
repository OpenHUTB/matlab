function registerImplParamInfo(this)


    baseRegisterImplParamInfo(this);


    this.addImplParamInfo('DSPStyle','ENUM','none',{'on','off','none'});
    this.addImplParamInfo('DotProductStrategy','ENUM','Fully Parallel',...
    {'Fully Parallel','Fully Parallel Scalarized','Serial Multiply-Accumulate','Parallel Multiply-Accumulate'});


    panelLayout=registerNFPImplParamInfo(this,true,true,true);

    this.addImplParamInfo('DivisionAlgorithm','ENUM','Radix-2',{'Radix-2','Radix-4'},panelLayout);
end
