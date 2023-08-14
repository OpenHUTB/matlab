function hNewC=SqrtBitsetWrapper(this,hN,hC)



    hInSignals=hC.PirInputSignals;
    hOutSignals=hC.PirOutputSignals;


    sqrtInfo=getBlockInfo(this,hC.SimulinkHandle);


    if hInSignals(1).Type.isMatrix&&hOutSignals(1).Type.isMatrix

        insertReshapeBefore(hN,hC,prod(hC.PirInputSignals(1).Type.Dimensions));

        insertReshapeAfter(hN,hC,prod(hC.PirOutputSignals(1).Type.Dimensions));

        hInSignals=hC.PirInputSignals;
        hOutSignals=hC.PirOutputSignals;
    end


    hSqrtNet=pirelab.getSqrtBitsetNetwork(hN,hInSignals,hOutSignals,sqrtInfo);


    hNewC=pirelab.instantiateNetwork(hN,hSqrtNet,hInSignals,hOutSignals,hC.Name);
    hN.renderCodegenPir(true);
end
