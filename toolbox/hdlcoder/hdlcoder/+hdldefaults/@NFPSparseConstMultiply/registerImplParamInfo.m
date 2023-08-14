function registerImplParamInfo(this)




    this.addImplParamInfo('SharingFactor','POSINT',0);
    this.addImplParamInfo('UseRAM','ENUM','off',{'on','off'});


    panelLayout=registerNFPImplParamInfo(this,false,false,true);

end
