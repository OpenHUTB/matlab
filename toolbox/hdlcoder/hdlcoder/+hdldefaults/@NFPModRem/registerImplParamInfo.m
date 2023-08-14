function registerImplParamInfo(this)





    baseRegisterImplParamInfo(this);


    panelLayout=registerNFPImplParamInfo(this,true);

    this.addImplParamInfo('CheckResetToZero','ENUM','on',{'on','off'},panelLayout);

end
