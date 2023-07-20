function[altMegaFunctionName,extraDir,status]=getCosMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)



    assert(logical(isEqual(inType,outType)));
    baseType=inType.getTargetCompDataTypeStr(outType,true);

    [altMegaFunctionName,extraDir,status]=alteratarget.getMegaFunctionCompWithOneInputFPF(targetCompInventory,baseType,className,[],latencyFreq,isFreqDriven,alteratarget.Cos,dryRun,deviceInfo,'','COS');
