function hNewC=elaborate(this,hN,hC)



    hCInSignals=hC.SLInputSignals;
    hCOutSignals=hC.SLOutputSignals;

    [rndMode,satMode]=this.getBlockInfo(hC);


    switch satMode
    case 'on'
        satModeVal='Saturate';
    case 'off'
        satModeVal='Wrap';
    end




    [~,hCInBaseType]=pirelab.getVectorTypeInfo(hCInSignals(2));
    dtcInSignal=this.insertDTCComp(hN,hC,hCInBaseType,hCOutSignals,rndMode,satModeVal);



    hNewC=pirelab.getSaturateDynamicComp(hN,hCInSignals,dtcInSignal,rndMode,satMode,hC.Name);

end



