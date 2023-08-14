function hNewC=lowerRecipSqrtNewton(hN,hC)



    newtonInfo.networkName=hC.Name;
    newtonInfo.rndMode=hC.getRoundingMode;
    newtonInfo.satMode=hC.getOverflowMode;
    newtonInfo.iterNum=hC.getIterNum;
    newtonInfo.intermDT=hC.getIntermDT;
    newtonInfo.internalRule=hC.getInternalRule;

    hNewC=pireml.getRecipSqrtNewtonComp(...
    hN,...
    hC.PirInputSignals,...
    hC.PirOutputSignals,...
    newtonInfo);
end
