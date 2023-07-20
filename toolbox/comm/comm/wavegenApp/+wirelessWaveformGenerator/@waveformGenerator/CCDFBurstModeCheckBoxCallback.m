







function CCDFBurstModeCheckBoxCallback(src,~)




    src.UserData.BurstMode=src.Value;
    ccdfResults=src.UserData;
    holdAxesLimits=src.Value;
    wirelessWaveformGenerator.waveformGenerator.plotCCDF(src.Parent.CurrentAxes,ccdfResults,holdAxesLimits);

end