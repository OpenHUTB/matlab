function hNew=addNfpSqrtComp(hN,latency,slRate,isSingle,isHalf)



    denormal=transformnfp.handleDenormal();
    if isSingle
        hNew=transformnfp.getSingleSqrtComp(hN,latency,slRate,denormal);
    elseif isHalf
        hNew=transformnfp.getHalfSqrtComp(hN,latency,slRate,denormal);
    else
        hNew=transformnfp.getDoubleSqrtComp(hN,latency,slRate,denormal);
    end
end
