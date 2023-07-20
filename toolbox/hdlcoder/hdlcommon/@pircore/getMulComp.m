function mulComp=getMulComp(hN,hInSignals,hOutSignals,...
    rndMode,satMode,compName,inputSigns,desc,slbh,dspMode,...
    nfpOptions,mulKind,matMulKind)

    narginchk(12,13);

    if(nargin<13)
        matMulKind='linear';
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

    if numel(hInSignals)==1&&(prod(hInSignals.Type.getDimensions)==prod(hOutSignals.Type.getDimensions))&&...
        ~contains(inputSigns,'/')

        if hInSignals.Type.isDoubleType||hInSignals.Type.isSingleType

            mulComp=pirelab.getWireComp(hN,hInSignals,hOutSignals);
        else

            mulComp=pirelab.getDTCComp(hN,hInSignals,hOutSignals,rndMode,satMode);
        end
    else
        if nfpOptions.Latency==int8(4)&&targetcodegen.targetCodeGenerationUtils.isNFPMode()
            out=hOutSignals;
            if targetmapping.mode(out)
                outType=out.Type.getLeafType;
                if outType.isSingleType
                    dataType='SINGLE';
                elseif outType.isHalfType
                    dataType='HALF';
                else
                    dataType='DOUBLE';
                end
                fc=hdlgetparameter('FloatingPointTargetConfiguration');
                if contains(inputSigns,'/')
                    ipSettings=fc.IPConfig.getIPSettings('Div',dataType);
                else
                    ipSettings=fc.IPConfig.getIPSettings('Mul',dataType);
                end

                if nfpOptions.CustomLatency>ipSettings.MaxLatency
                    nfpOptions.CustomLatency=ipSettings.MaxLatency;
                end
            end
        end

        mulComp=hN.addComponent2(...
        'kind','multiply',...
        'SimulinkHandle',slbh,...
        'name',compName,...
        'InputSignals',hInSignals,...
        'OutputSignals',hOutSignals,...
        'RoundingMode',rndMode,...
        'OverflowMode',satMode,...
        'BlockComment',desc,...
        'DSPStyle',dspMode,...
        'InputSigns',inputSigns,...
        'NFPLatency',nfpOptions.Latency,...
        'NFPCustomLatency',nfpOptions.CustomLatency,...
        'NFPMantMul',nfpOptions.MantMul,...
        'NFPDenormals',nfpOptions.Denormals,...
        'NFPRadix',nfpOptions.Radix,...
        'Multiplication',mulKind,...
        'MatMultKind',matMulKindInt);

        mulComp.setSupportAlteraMegaFunctions(true);
        mulComp.setSupportXilinxCoreGen(true);

    end
end


