function hNewC=elaborate(this,hN,hC)



    [roundingMode,satMode,nfpOptions,isComplex]=getBlockInfo(this,hC);

    hNewC=pirelab.getAbsComp(hN,hC.SLInputSignals,hC.SLOutputSignals,...
    roundingMode,satMode,hC.Name,nfpOptions,isComplex);
end
