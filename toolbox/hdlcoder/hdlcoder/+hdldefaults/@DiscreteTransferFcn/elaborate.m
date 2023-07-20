function hNewC=elaborate(this,hN,hC)


    hCInSignal=hC.PirInputSignals;
    hCOutSignal=hC.PirOutputSignals;


    [tfInfo,nfpOptions]=this.getBlockInfo(hC);





























    tfComp=pirelab.getDiscreteTransferFcnComp(hN,hCInSignal,...
    hCOutSignal,tfInfo,nfpOptions);
    hNewC=tfComp;


end
