function hNewC=elaborate(this,hN,hC)



    hCInSignals=hC.SLInputSignals;
    hCOutSignals=hC.SLOutputSignals;

    [lowerLimit,upperLimit,rndMode,~]=this.getBlockInfo(hC);

    [~,hCOutBaseType]=pirelab.getVectorTypeInfo(hCOutSignals);
    dtcOutSignal=pirelab.insertDTCCompOnInput(hN,hCInSignals,hCOutBaseType,rndMode,'saturate');

    hNewC=pirelab.getSaturateComp(hN,dtcOutSignal,hCOutSignals,lowerLimit,upperLimit,rndMode,hC.Name);

end
