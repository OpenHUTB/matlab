function registerImplParamInfo(this)


    baseRegisterImplParamInfo(this);


    panelLayout=registerNFPImplParamInfo(this,true,true,false);

    this.addImplParamInfo('DivisionAlgorithm','ENUM','Radix-2',{'Radix-2','Radix-4'},panelLayout);
end
