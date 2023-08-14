function[altMegaFunctionName,extraDir,status]=getAddMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)



    assert(logical(isEqual(inType,outType)));
    baseType=inType.getTargetCompDataTypeStr(outType,true);

    [altMegaFunctionName,extraDir,status]=alteratarget.getMegaFunctionCompWithTwoInputsFPF(targetCompInventory,baseType,className,'ADD',latencyFreq,isFreqDriven,alteratarget.AddSub,dryRun,deviceInfo);

