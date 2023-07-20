function hNewC=elaborate(this,hN,hC)



    hCInSignals=hC.SLInputSignals;
    hCOutSignals=hC.SLOutputSignals;



    [~,hCInBaseType]=pirelab.getVectorTypeInfo(hCInSignals(2));
    dtcInSignal=this.insertDTCComp(hN,hC,hCInBaseType,hCOutSignals);



    hNewC=pirelab.getDeadZoneDynamicComp(hN,hCInSignals,dtcInSignal,hC.Name);

end



