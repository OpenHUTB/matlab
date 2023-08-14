function[altMegaFunctionName,extraDir,status]=getSubMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)



    assert(logical(isEqual(inType,outType)));
    baseType=inType.getTargetCompDataTypeStr(outType,true);

    [altMegaFunctionName,extraDir,status]=alteratarget.getMegaFunctionCompWithTwoInputsFPF(targetCompInventory,baseType,className,'SUB',latencyFreq,isFreqDriven,alteratarget.AddSub,dryRun,deviceInfo);

