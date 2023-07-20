function hNew=addNfpFixComp(hN,latency,slRate,isSingle)
    if isSingle
        hNew=transformnfp.getSingleFixComp(hN,latency,slRate);
    else
        hNew=transformnfp.getDoubleFixComp(hN,latency,slRate);
    end
end
