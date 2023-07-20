function hNew=addNfpATan2Comp(hN,slRate,isSingle)
    denormal=transformnfp.handleDenormal();
    if isSingle
        hNew=transformnfp.getSingleATan2Comp(hN,slRate,denormal);
    else
        hNew=transformnfp.getDoubleATan2Comp(hN,slRate,denormal);
    end
end
