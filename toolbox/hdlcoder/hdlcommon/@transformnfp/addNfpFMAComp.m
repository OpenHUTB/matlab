function hNew=addNfpFMAComp(hN,slRate,isSingle)


    denormal=transformnfp.handleDenormal();
    mantMulStrategy=transformnfp.mantissaMultiplyStrategy;
    partAddShiftMulSize=transformnfp.partAddShiftMultiplierSize;

    if isSingle
        hNew=transformnfp.getSingleFMAComp(hN,slRate,denormal,mantMulStrategy,partAddShiftMulSize);
    else
        hNew=transformnfp.getDoubleFMAComp(hN,slRate,denormal,mantMulStrategy,partAddShiftMulSize);
    end
end
