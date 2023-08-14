function hNewC=elaborate(this,hN,hC)


    newtonInfo=getBlockInfo(this,hC);
    hNewC=pirelab.getReciprocalComp(hN,hC.PirInputSignals,hC.PirOutputSignals,...
    newtonInfo,hC.SimulinkHandle);
end
