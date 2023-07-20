function dtcInSignal=insertDTCComp(this,hN,hC,hcInType,hCOutSignal,rndMode,satMode)





    if(nargin<7)
        satMode=0;
    end


    [dimLenOut,hcOutType]=pirelab.getVectorTypeInfo(hCOutSignal);

    if(hcInType.isEqual(hcOutType))

        dtcInSignal=hCOutSignal;
        return;
    end


    if hCOutSignal.Type.isArrayType
        dtcInType=pirelab.getPirVectorType(hcInType,dimLenOut);
    else
        dtcInType=hcInType;
    end


    hcOutName=hCOutSignal.Name;
    dtcInSignal=hN.addSignal(dtcInType,[hcOutName,'_dtc']);


    pirelab.getDTCComp(hN,dtcInSignal,hCOutSignal,rndMode,satMode);


