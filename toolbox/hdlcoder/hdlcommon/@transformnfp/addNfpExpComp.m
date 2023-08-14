function hNew=addNfpExpComp(hN,latency,slRate,isSingle,isHalf)
    denormal=transformnfp.handleDenormal();
    if isSingle
        hNew=transformnfp.getSingleExpPow10Comp(hN,slRate,'exp',denormal);
    elseif isHalf
        hNew=transformnfp.getHalfExpComp(hN,latency,slRate,denormal);
    else
        hNew=transformnfp.getDoubleExpComp(hN,slRate);
    end
end
