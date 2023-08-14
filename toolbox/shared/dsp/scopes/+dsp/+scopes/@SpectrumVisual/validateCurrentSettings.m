function validFlag=validateCurrentSettings(this)





    clearCorrectionMode(this);


    [validFlag,errStr]=validateSpectrumSettings(this);
    setPropertyValue(this,'IsCorrectionMode',~validFlag);
    updateCorrectionModeMessage(this,~validFlag,errStr);

    this.IsNotInCorrectionMode=~getPropertyValue(this,'IsCorrectionMode');
end
