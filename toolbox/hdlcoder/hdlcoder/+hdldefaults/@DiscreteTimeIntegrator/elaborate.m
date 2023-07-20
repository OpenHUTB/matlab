function hNewC=elaborate(this,hN,hC)









    [dtiInfo,nfpOptions]=this.getBlockInfo(hC.SimulinkHandle);


    if hC.PirInputSignals(1).Type.isMatrix&&hC.PirOutputSignals(1).Type.isMatrix

        insertReshapeBefore(hN,hC,prod(hC.PirInputSignals(1).Type.Dimensions));

        insertReshapeAfter(hN,hC,prod(hC.PirOutputSignals(1).Type.Dimensions));
    end


    hNewC=pirelab.getDiscreteTimeIntegratorComp(hN,hC.PirInputSignals,...
    hC.PirOutputSignals,dtiInfo,nfpOptions);
end