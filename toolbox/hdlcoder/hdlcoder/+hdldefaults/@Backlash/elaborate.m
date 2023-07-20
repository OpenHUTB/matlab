function hNewC=elaborate(this,hN,hC)



    hCInSignals=hC.SLInputSignals;
    hCOutSignals=hC.SLOutputSignals;

    [backlashWidth,initialOutput]=this.getBlockInfo(hC);

    hNewC=pirelab.getBacklashComp(hN,hCInSignals,hCOutSignals,backlashWidth,initialOutput,hC.Name);

end
