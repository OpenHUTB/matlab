function hNew=addNfpPow10Comp(hN,slRate,isSingle)
    denormal=transformnfp.handleDenormal();
    if isSingle
        hNew=transformnfp.getSingleExpPow10Comp(hN,slRate,'pow10',denormal);
    end
end
