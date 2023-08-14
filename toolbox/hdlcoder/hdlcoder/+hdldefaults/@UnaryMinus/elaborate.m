function hNewC=elaborate(this,hN,hC)



    [satMode]=getBlockInfo(this,hC);


    hNewC=pirelab.getUnaryMinusComp(hN,hC.SLInputSignals,hC.SLOutputSignals,satMode,hC.Name);

end
