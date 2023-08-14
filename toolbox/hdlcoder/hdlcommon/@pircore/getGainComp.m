function gainComp=getGainComp(hN,hInSignals,hOutSignals,gainFactor,gainMode,constMultiplierOptimMode,...
    roundMode,satMode,compName,dspMode,TunableParamStr,TunableParamType,nfpOptions,...
    matMulKind)





    if(nargin<14)
        matMulKind='linear';
    end

    if nargin<13
        nfpOptions.Latency=int8(0);
        nfpOptions.MantMul=int8(0);
        nfpOptions.Denormals=int8(0);
    end

    if nargin<12
        TunableParamType=[];
    end

    if nargin<11
        TunableParamStr='';
    end

    if nargin<10
        dspMode=int8(0);
    end

    if(nargin<9)
        compName='gain';
    end

    if(nargin<8)
        satMode='Wrap';
    end

    if(nargin<7)
        roundMode='Floor';
    end

    if(nargin<6)
        constMultiplierOptimMode=0;
    end

    if(nargin<5)
        gainMode=1;
    end


    switch matMulKind
    case 'serialmac'
        matMulKindInt=1;
    case 'parallelmac'
        matMulKindInt=2;
    case 'scalarized'
        matMulKindInt=3;
    otherwise
        matMulKindInt=0;
    end

    if~isfield(nfpOptions,'CustomLatency')
        nfpOptions.CustomLatency=int8(0);
    end

    gainFactorEx=pirelab.convertInt2fi(gainFactor);





    gainFactorDims=size(gainFactorEx);
    hT=hInSignals.Type;
    isInputTreatedAs1D=~(hT.isArrayType&&hT.NumberOfDimensions>1)&&...
    any(hT.getDimensions>1)&&~hT.isColumnVector&&~hT.isRowVector;
    if gainMode==1&&isInputTreatedAs1D&&gainFactorDims(1)==1

        gainFactorEx=gainFactorEx.';
    end

    if(isBooleanType(hInSignals.Type.getLeafType)&&isBooleanType(hOutSignals.Type.getLeafType)&&...
        all(gainFactorEx~=0,'all')&&(isempty(TunableParamStr))&&gainMode==1)




        gainComp=pirelab.getWireComp(hN,hInSignals,hOutSignals);
        return;
    end

    gainComp=hN.addComponent2(...
    'kind','gain_comp',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'GainValue',gainFactorEx,...
    'GainMode',gainMode,...
    'RoundingMode',roundMode,...
    'OverflowMode',satMode,...
    'DSPStyle',dspMode,...
    'ConstMultiplierMode',constMultiplierOptimMode,...
    'TunableParamStr',TunableParamStr,...
    'TunableParamType',TunableParamType,...
    'NFPLatency',nfpOptions.Latency,...
    'NFPCustomLatency',nfpOptions.CustomLatency,...
    'NFPMantMul',nfpOptions.MantMul,...
    'NFPDenormals',nfpOptions.Denormals,...
    'MatMultKind',matMulKindInt);

    gainComp.setSupportAlteraMegaFunctions(true);

end


