function hNewC=lowerReciprocal(hN,hC)



    newtonInfo.networkName=hC.Name;
    newtonInfo.rndMode=hC.getRoundingMode;
    newtonInfo.satMode=hC.getOverflowMode;
    newtonInfo.iterNum=hC.getIterNum;
    newtonInfo.intermDT=hC.getIntermDT;
    newtonInfo.internalRule=hC.getInternalRule;
    newtonInfo.isMultirate=hC.getIsMultirate;
    newtonInfo.upFactor=hC.getUpFactor;
    newtonInfo.isRsqrtBased=hC.getIsRsqrtBased;

    hNewC=pireml.getReciprocalComp(...
    hN,...
    hC.PirInputSignals,...
    hC.PirOutputSignals,...
    newtonInfo);
end
