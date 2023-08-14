function hNew=addNfpMulComp(hN,latency,slRate,isSingle,isHalf)



    denormal=transformnfp.handleDenormal();
    mantMulStrategy=transformnfp.mantissaMultiplyStrategy;
    partAddShiftMulSize=transformnfp.partAddShiftMultiplierSize;

    if isSingle
        hNew=transformnfp.getSingleMulComp(hN,latency,slRate,denormal,mantMulStrategy,partAddShiftMulSize);
    elseif isHalf
        hNew=transformnfp.getHalfMulComp(hN,latency,slRate,denormal,mantMulStrategy);
    else
        hNew=transformnfp.getDoubleMulComp(hN,slRate,latency,denormal);
    end
end
