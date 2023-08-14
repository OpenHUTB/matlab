function hNewC=elaborate(this,hN,hC)



    hCInSignals=hC.SLInputSignals;
    hCOutSignals=hC.SLOutputSignals;

    [lowerLimit,upperLimit,rndMode,satMode]=this.getBlockInfo(hC);

    [~,hCOutBaseType]=pirelab.getVectorTypeInfo(hCOutSignals);
    dtcOutSignal=pirelab.insertDTCCompOnInput(hN,hCInSignals,hCOutBaseType,rndMode,satMode);

    hNewC=pirelab.getDeadZoneComp(hN,dtcOutSignal,hCOutSignals,lowerLimit,upperLimit,hC.Name);

end
