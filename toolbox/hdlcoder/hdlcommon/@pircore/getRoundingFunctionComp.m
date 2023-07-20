function roundingComp=getRoundingFunctionComp(hN,hInSignals,hOutSignals,op,compName,nfpOptions)




    if nargin<6
        nfpOptions.Latency=int8(0);
        nfpOptions.MantMul=int8(0);
        nfpOptions.Denormals=int8(0);
    end

    if(nargin<5)
        compName='RoundingFunction';
    end

    if(nargin<4)
        op='floor';
    end
    if~isfield(nfpOptions,'CustomLatency')
        nfpOptions.CustomLatency=int8(0);
    end
    roundingComp=hN.addComponent2(...
    'kind','rounding_comp',...
    'name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'OperatorMode',op,...
    'NFPLatency',nfpOptions.Latency,...
    'NFPCustomLatency',nfpOptions.CustomLatency);

end
