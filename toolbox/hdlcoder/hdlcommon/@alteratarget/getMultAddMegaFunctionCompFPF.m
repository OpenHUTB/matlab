function[altMegaFunctionName,extraDir,status]=getMultAddMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)



    assert(logical(isEqual(inType,outType)));
    baseType=inType.getTargetCompDataTypeStr(outType,true);

    [altMegaFunctionName,extraDir,status]=alteratarget.getMegaFunctionCompWithThreeInputsFPF(targetCompInventory,baseType,className,'MULT_ADD',latencyFreq,isFreqDriven,alteratarget.MultAdd,dryRun,deviceInfo);
