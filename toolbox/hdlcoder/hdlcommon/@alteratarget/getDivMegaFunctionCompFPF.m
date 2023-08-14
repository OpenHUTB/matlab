function[altMegaFunctionName,extraDir,status]=getDivMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)



    assert(logical(isEqual(inType,outType)));
    baseType=inType.getTargetCompDataTypeStr(outType,true);

    [altMegaFunctionName,extraDir,status]=alteratarget.getMegaFunctionCompWithTwoInputsFPF(targetCompInventory,baseType,className,'div',latencyFreq,isFreqDriven,alteratarget.Div,dryRun,deviceInfo);

