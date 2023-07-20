function hNew=addNfpRoundComp(hN,latency,slRate,isSingle)
    if isSingle
        hNew=transformnfp.getSingleRoundComp(hN,latency,slRate);
    else
        hNew=transformnfp.getDoubleRoundComp(hN,latency,slRate);
    end
end
