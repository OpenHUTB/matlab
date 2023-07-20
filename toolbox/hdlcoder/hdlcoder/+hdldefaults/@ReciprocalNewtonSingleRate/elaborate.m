function hNewC=elaborate(this,hN,hC)


    newtonInfo=getBlockInfo(this,hC);
    nfpOptions=getNFPBlockInfo(this);
    hNewC=pirelab.getReciprocalComp(hN,hC.PirInputSignals,hC.PirOutputSignals,...
    newtonInfo,hC.SimulinkHandle,nfpOptions);
end
