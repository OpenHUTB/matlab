function hNewC=elaborate(this,hN,hC)






    info=getBlockInfo(this,hC.SimulinkHandle);
    info.for_comments=hC;
    RAMDirective=getImplParams(this,'RAMDirective');


    if info.isFWFT
        hFIFONet=pirelab.getFIFOFWFTNetwork(hN,hC.PirInputSignals,info,RAMDirective);
    else
        hFIFONet=pirelab.getFIFONetwork(hN,hC.PirInputSignals,hC.PirOutputSignals,info,'',RAMDirective);
    end
    hFIFONet.copyComment(hC);


    hNewC=pirelab.instantiateNetwork(hN,hFIFONet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);
