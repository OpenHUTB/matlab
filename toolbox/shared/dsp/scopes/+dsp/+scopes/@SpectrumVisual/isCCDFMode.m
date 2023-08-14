function flag=isCCDFMode(this)




    flag=this.CCDFModeEnable&&~isFrequencyInputMode(this);
end
