function status=getCodeForTwoInputsFPF(targetCompInventory,hInSignals,hOutSignals,className,mnemonic,pipeline,fpFunction,fpSpecificArgs,nameSuffix)

    if(nargin<9)
        fpSpecificArgs='';
    end

    if(nargin<10)
        nameSuffix='';
    end

    status=0;

    if~targetmapping.isValidDataType(hInSignals(1).Type)...
        &&~targetmapping.isValidDataType(hOutSignals(1).Type)
        return;
    end

    [~,baseType]=pirelab.getVectorTypeInfo(hInSignals(1));

    altMegaFunctionName=alteratarget.generateMegafunctionName(baseType,className,lower(mnemonic));
    if(~isempty(nameSuffix))
        altMegaFunctionName=[altMegaFunctionName,'_',nameSuffix];
    end
    ipgArgs=alteratarget.generateMegafunctionParamsFileFPF(baseType,fpFunction,fpSpecificArgs,altMegaFunctionName,pipeline,mnemonic);


    status=alteratarget.generateMegafunctionFPF(targetCompInventory,altMegaFunctionName,ipgArgs,pipeline);
end
