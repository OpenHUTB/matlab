function[altMegaFunctionName,extraDir,status]=getAbsMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)



    assert(logical(isEqual(inType,outType)));
    baseType=inType.getTargetCompDataTypeStr(outType,true);

    [altMegaFunctionName,extraDir,status]=alteratarget.getMegaFunctionCompWithOneInputFPF(targetCompInventory,baseType,className,[],latencyFreq,isFreqDriven,alteratarget.Abs,dryRun,deviceInfo);

