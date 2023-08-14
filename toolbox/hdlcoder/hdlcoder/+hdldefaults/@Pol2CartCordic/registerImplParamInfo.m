function registerImplParamInfo(this)


    baseRegisterImplParamInfo(this);


    panelLayout=registerNFPImplParamInfo(this,true,true);
    this.addImplParamInfo('InputRangeReduction','ENUM','on',{'on','off'},panelLayout);
end
