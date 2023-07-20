function[altMegaFunctionName,extraDir,status]=getInvMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)



    assert(logical(isEqual(inType,outType)));
    baseType=inType.getTargetCompDataTypeStr(outType,true);

    [altMegaFunctionName,extraDir,status]=alteratarget.getMegaFunctionCompWithOneInputFPF(targetCompInventory,baseType,className,'Inv',latencyFreq,isFreqDriven,alteratarget.Recip,dryRun,deviceInfo);
