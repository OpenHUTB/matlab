function hNewC=elaborateMain(this,hN,hC)





    slbh=hC.SimulinkHandle;
    fcnString=this.getBlockInfo(slbh);

    hNewNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC);


    if(strcmpi(hN.getFlattenHierarchy(),'on')||hN.hasUserFlattenedNics())
        hNewNet.setFlattenHierarchy('on');
    end

    if strcmpi(fcnString,'Value')
        this.elaborateCascadeMinMaxValue(hNewNet,hC);
    elseif strcmpi(fcnString,'Index')
        this.elaborateCascadeMinMaxValueAndIndex(hNewNet,hC);
    elseif strcmpi(fcnString,'Value and Index')
        this.elaborateCascadeMinMaxValueAndIndex(hNewNet,hC);
    else
        error(message('hdlcoder:validate:unsupportedminmax',this.localGetBlockName(slbh)));
    end

    hCInSignal=hC.PirInputSignals;
    hCOutSignal=hC.PirOutputSignals;
    hNewC=pirelab.instantiateNetwork(hN,hNewNet,hCInSignal,hCOutSignal,hC.Name);

