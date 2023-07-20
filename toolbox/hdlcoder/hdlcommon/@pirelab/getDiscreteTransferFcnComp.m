function tfComp=getDiscreteTransferFcnComp(hN,hInSignals,hOutSignals,tfInfo,nfpOptions)













































    if nargin<5
        nfpOptions.Latency=int8(0);
        nfpOptions.MantMul=int8(0);
        nfpOptions.Denormals=int8(0);
    end

    archData.Denominator=tfInfo.Denominator;
    archData.Numerator=tfInfo.Numerator;
    archData.InitialStates=tfInfo.InitialStates;

    LD=length(archData.Denominator);
    LN=length(archData.Numerator);

    L=max(LD,LN);



    if L>LN
        temp=archData.Numerator(1);
        temp(length(archData.Numerator)+L-LN)=0;
        temp(1)=0;
        temp(L-LN+1:end)=archData.Numerator;
        archData.Numerator=temp;
    end
    if L>LD
        temp=archData.Denominator(1);
        temp(length(archData.Denominator)+L-LN)=0;
        temp(1)=0;
        temp(L-LN:end)=archData.Denominator;
        archData.Denominator=temp;
    end

    if isscalar(tfInfo.InitialStates)

        temp=tfInfo.InitialStates;
        temp(L)=tfInfo.InitialStates;
        temp(:)=tfInfo.InitialStates;
        archData.InitialStates=temp;
    else
        archData.InitialStates=tfInfo.InitialStates;
    end





    archData.Denominator(1)=1/double(archData.Denominator(1));


    archData.Denominator=pirelab.getTypeInfoAsFi(tfInfo.DenCoefDataType,...
    'Nearest','Saturate',archData.Denominator);
    archData.Numerator=pirelab.getTypeInfoAsFi(tfInfo.NumCoefDataType,...
    'Nearest','Saturate',archData.Numerator);
    archData.InitialStates=pirelab.getTypeInfoAsFi(tfInfo.StateDataType,...
    'Nearest','Saturate',archData.InitialStates);


    archData.a0EqualsOne=tfInfo.a0EqualsOne;

    archData.StateDataType=tfInfo.StateDataType;

    archData.NumCoefDataType=tfInfo.NumCoefDataType;
    archData.DenCoefDataType=tfInfo.DenCoefDataType;

    archData.NumProductDataType=tfInfo.NumProductDataType;
    archData.DenProductDataType=tfInfo.DenProductDataType;

    archData.NumAccumDataType=tfInfo.NumAccumDataType;
    archData.DenAccumDataType=tfInfo.DenAccumDataType;

    archData.gainMode=tfInfo.gainMode;
    archData.convMode=tfInfo.convMode;
    archData.rndMode=tfInfo.rndMode;
    archData.satMode=tfInfo.satMode;
    archData.resetnone=tfInfo.resetnone;





    archData.constMultiplierOptimMode=tfInfo.constMultiplierOptimMode;






    tfComp=hdlarch.filterArch.getDirectFormIIStruct(...
    hN,hInSignals,hOutSignals,...
    archData.Numerator,...
    archData.Denominator,...
    archData.StateDataType,...
    archData.a0EqualsOne,...
    archData.NumProductDataType,...
    archData.DenProductDataType,...
    archData.NumAccumDataType,...
    archData.DenAccumDataType,...
    archData.rndMode,...
    archData.satMode,...
    archData.convMode,...
    archData.constMultiplierOptimMode,...
    archData.gainMode,...
    archData.resetnone,...
    archData.InitialStates,...
    archData.DenCoefDataType,...
    archData.NumCoefDataType,...
    nfpOptions);


end


