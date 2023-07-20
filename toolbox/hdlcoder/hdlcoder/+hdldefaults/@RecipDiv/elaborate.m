function hNewC=elaborate(this,hN,hC)




    newtonInfo=getBlockInfo(this,hC.SimulinkHandle);
    hNewC=pirelab.getReciprocalComp(hN,hC.PirInputSignals,hC.PirOutputSignals,...
    newtonInfo,this);
end
