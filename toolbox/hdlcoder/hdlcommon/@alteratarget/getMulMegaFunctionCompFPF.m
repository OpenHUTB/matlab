function[altMegaFunctionName,extraDir,status]=getMulMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)



    assert(logical(isEqual(inType,outType)));
    baseType=inType.getTargetCompDataTypeStr(outType,true);

    [altMegaFunctionName,extraDir,status]=alteratarget.getMegaFunctionCompWithTwoInputsFPF(targetCompInventory,baseType,className,[],latencyFreq,isFreqDriven,alteratarget.Mul,dryRun,deviceInfo);

