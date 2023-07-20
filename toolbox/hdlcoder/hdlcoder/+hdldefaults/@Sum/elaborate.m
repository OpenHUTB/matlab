function addComp=elaborate(this,hN,hC)



    [rndMode,ovMode,accType,inputSigns]=this.getBlockInfo(hC);

    hCInSignals=hC.PirInputSignals;
    hCOutSignals=hC.PirOutputSignals;

    nfpOptions=this.getNFPImplParamInfo(hC);
    if hC.PirOutputSignals(1).Type.isMatrix
        traceComment=hC.getComment;
    else
        traceComment='';
    end

    if numel(hCInSignals)==1
        hNewNet=createNetworkWithComponent(hN,hC);

        pirelab.getAddComp(hNewNet,hNewNet.PirInputSignals,hNewNet.PirOutputSignals,rndMode,...
        ovMode,hC.Name,accType,inputSigns,'',-1,nfpOptions,traceComment);
        addComp=pirelab.instantiateNetwork(hN,hNewNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);
    else

        addComp=pirelab.getAddComp(hN,hCInSignals,hCOutSignals,rndMode,...
        ovMode,hC.Name,accType,inputSigns,'',-1,nfpOptions,traceComment);
    end
end

function hNewNet=createNetworkWithComponent(hN,hC)

    hNewNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC);



    for ii=1:length(hC.PirInputSignals)
        hNewNet.PirInputSignals(ii).SimulinkRate=hC.PirInputSignals(ii).SimulinkRate;
    end

    for ii=1:length(hC.PirOutputSignals)
        hNewNet.PirOutputSignals(ii).SimulinkRate=hC.PirOutputSignals(ii).SimulinkRate;
    end

    hNewNet.setFlattenHierarchy('on');
end
