function hNew=addNfpHDLRecipComp(hN,slRate,numIters,isSingle)
    denormal=transformnfp.handleDenormal();
    if isSingle
        hNew=transformnfp.getSingleHDLRecipComp(hN,slRate,denormal,numIters);
    else
        hNew=transformnfp.getDoubleHDLRecipComp(hN,slRate,denormal,numIters);
    end
end
