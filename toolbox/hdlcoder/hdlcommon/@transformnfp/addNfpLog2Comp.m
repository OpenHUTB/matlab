function hNew=addNfpLog2Comp(hN,slRate,isSingle)
    denormal=transformnfp.handleDenormal();
    if isSingle
        hNew=transformnfp.getSingleLog2Comp(hN,slRate,denormal);
    end
end
