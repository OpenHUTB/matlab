function registerImplParamInfo(this)




    baseRegisterImplParamInfo(this);


    this.addImplParamInfo('DSPStyle','ENUM','none',{'on','off','none'});


    panelLayout=registerNFPImplParamInfo(this,true,true,true);

    this.addImplParamInfo('DivisionAlgorithm','ENUM','Radix-2',{'Radix-2','Radix-4'},panelLayout);
end
