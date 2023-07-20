function registerImplParamInfo(this)





    baseRegisterImplParamInfo(this);


    panelLayout=registerNFPImplParamInfo(this,true);

    this.addImplParamInfo('InputRangeReduction','ENUM','on',{'on','off'},panelLayout);

    this.addImplParamInfo('MultiplyStrategy','ENUM','inherit',{'inherit','FullMultiplier','PartMultiplierPartAddShift'},panelLayout);
