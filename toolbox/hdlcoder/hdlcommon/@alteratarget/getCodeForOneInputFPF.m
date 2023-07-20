function status=getCodeForOneInputFPF(targetCompInventory,hInSignals,hOutSignals,className,mnemonic,pipeline,fpFunction,fpSpecificArgs,nameSuffix)

    if(nargin<9)
        fpSpecificArgs='';
    end

    if(nargin<10)
        nameSuffix='';
    end

    status=0;

    if(targetmapping.isValidDataType(hInSignals(1).Type))
        [~,baseType]=pirelab.getVectorTypeInfo(hInSignals(1));
    elseif(targetmapping.isValidDataType(hOutSignals(1).Type))
        [~,baseType]=pirelab.getVectorTypeInfo(hOutSignals(1));
    else
        return;
    end

    altMegaFunctionName=alteratarget.generateMegafunctionName(baseType,className,lower(mnemonic));
    if(~isempty(nameSuffix))
        altMegaFunctionName=[altMegaFunctionName,'_',nameSuffix];
    end
    ipgArgs=alteratarget.generateMegafunctionParamsFileFPF(baseType,fpFunction,fpSpecificArgs,altMegaFunctionName,pipeline,mnemonic);


    status=alteratarget.generateMegafunctionFPF(targetCompInventory,altMegaFunctionName,ipgArgs,pipeline);

