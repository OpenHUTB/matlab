function[altMegaFunctionName,extraDir,status]=getMegaFunctionCompWithThreeInputsFPF(targetCompInventory,baseType,className,mnemonic,latencyFreq,isFreqDriven,fpFunction,dryRun,deviceInfo,fpSpecificArgs,nameSuffix)






    if(nargin<9)
        assert(0);
    end

    if(nargin<10)
        fpSpecificArgs='';
    end

    if(nargin<11)
        nameSuffix='';
    end

    altMegaFunctionName=alteratarget.generateMegafunctionNameFPF(baseType,className,lower(mnemonic));
    if(~isempty(nameSuffix))
        altMegaFunctionName=[altMegaFunctionName,'_',nameSuffix];
    end

    numOfInst=0;
    ipgArgs=alteratarget.generateMegafunctionParamsFileFPF(baseType,fpFunction,fpSpecificArgs,altMegaFunctionName,latencyFreq,isFreqDriven,mnemonic,deviceInfo);

    status=alteratarget.generateMegafunctionFPF(targetCompInventory,altMegaFunctionName,ipgArgs,latencyFreq,isFreqDriven,numOfInst,dryRun,deviceInfo);
    extraDir=alteratarget.getExtraDir(ipgArgs,deviceInfo{1});
end

