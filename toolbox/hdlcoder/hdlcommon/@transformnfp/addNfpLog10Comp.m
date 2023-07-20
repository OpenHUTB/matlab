function hNew=addNfpLog10Comp(hN,latency,slRate,isSingle,isHalf)
    denormal=transformnfp.handleDenormal();
    if isSingle
        hNew=transformnfp.getSingleLog10Comp(hN,slRate,denormal);
    elseif isHalf
        hNew=transformnfp.getHalfLog10Comp(hN,latency,slRate,denormal);
    end
end
