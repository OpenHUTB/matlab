function hNew=addNfpPow2Comp(hN,slRate,isSingle)
    denormal=transformnfp.handleDenormal();
    if isSingle
        hNew=transformnfp.getSinglePow2Comp(hN,slRate,denormal);
    end
end
