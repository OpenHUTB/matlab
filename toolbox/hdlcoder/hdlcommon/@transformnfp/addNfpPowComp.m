function hNew=addNfpPowComp(hN,slRate,isSingle)
    denormal=transformnfp.handleDenormal();
    if isSingle
        hNew=transformnfp.getSinglePowComp(hN,slRate,denormal);
    end
end
