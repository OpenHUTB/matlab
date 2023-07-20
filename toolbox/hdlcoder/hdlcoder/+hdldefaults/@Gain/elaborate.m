function hNewC=elaborate(this,hN,hC)


    constMultiplierOptimParam=getImplParams(this,'ConstMultiplierOptimization');
    constMultiplierOptimMode=0;
    if~isempty(constMultiplierOptimParam)
        if strcmpi(constMultiplierOptimParam,'none')
            constMultiplierOptimMode=0;
        elseif strcmpi(constMultiplierOptimParam,'csd')
            constMultiplierOptimMode=1;
        elseif strcmpi(constMultiplierOptimParam,'fcsd')
            constMultiplierOptimMode=2;
        elseif strcmpi(constMultiplierOptimParam,'auto')
            constMultiplierOptimMode=3;
        end
    end

    dspModeStr=getImplParams(this,'DSPStyle');
    dspMode=int8(0);

    if isempty(dspModeStr)
        dspMode=int8(0);
    elseif strcmpi(dspModeStr,'on')
        dspMode=int8(1);
    elseif strcmpi(dspModeStr,'off')
        dspMode=int8(2);
    end

    v=this.validateDSPStyle(hC);
    if(numel(v)>1)
        dspMode=int8(0);
    end

    gainParamGeneric=hN.IsNameGenericPort(get_param(hC.SimulinkHandle,'Gain'));

    slbh=hC.SimulinkHandle;
    multiMode=get_param(slbh,'Multiplication');
    if strcmpi(multiMode,'Element-wise(K.*u)')
        gainMode=1;
    elseif strcmpi(multiMode,'Matrix(u*K)')
        gainMode=2;
    elseif strcmpi(multiMode,'Matrix(K*u)')
        gainMode=3;
    else
        gainMode=4;
    end

    rndMode=get_param(slbh,'RndMeth');
    sat=get_param(slbh,'DoSatur');
    if strcmp(sat,'on')
        satMode='Saturate';
    else
        satMode='Wrap';
    end
    matMulStrategy=getMatMulStrategy(this,hC);
    matMulKind='linear';
    if~isempty(matMulStrategy)
        if strcmpi(matMulStrategy,'Serial Multiply-Accumulate')
            matMulKind='serialmac';
        elseif strcmpi(matMulStrategy,'Parallel Multiply-Accumulate')
            matMulKind='parallelmac';
        elseif strcmpi(matMulStrategy,'Fully Parallel Scalarized')
            matMulKind='scalarized';
        end
    end

    [gainFactor,nfpOptions,TunableParamStr,TunableParamType]=this.getBlockDialogValue(slbh);

    traceComment=hC.getComment;

    hNewC=pirelab.getGainComp(hN,hC.SLInputSignals,hC.SLOutputSignals,...
    gainFactor,gainMode,constMultiplierOptimMode,rndMode,satMode,...
    hC.Name,dspMode,TunableParamStr,TunableParamType,gainParamGeneric,...
    nfpOptions,traceComment,matMulKind);
end


