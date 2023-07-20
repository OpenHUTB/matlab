function hNew=addNfpRSqrtComp(hN,latency,slRate,isSingle)
    if isSingle
        hNew=transformnfp.getSingleRSqrtComp(hN,latency,slRate);
    else
        hNew=transformnfp.getDoubleRSqrtComp(hN,latency,slRate);
    end
end
