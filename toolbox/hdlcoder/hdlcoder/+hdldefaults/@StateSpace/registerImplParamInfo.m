function registerImplParamInfo(this)


    baseRegisterImplParamInfo(this);


    this.addImplParamInfo('DSPStyle','ENUM','none',{'on','off','none'});
    this.addImplParamInfo('DotProductStrategy','ENUM','Fully Parallel',...
    {'Fully Parallel','Fully Parallel Scalarized','Parallel Multiply-Accumulate'});
end
