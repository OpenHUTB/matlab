function hNewC=elaborate(this,hN,hC)



    hCInSignals=hC.SLInputSignals;
    hCOutSignals=hC.SLOutputSignals;

    [hcOffset,hcDirectionMode]=this.getBlockInfo(hC);

    hNewC=pirelab.getHitCrossComp(hN,hCInSignals,hCOutSignals,hcOffset,hcDirectionMode,hC.Name);

end
