function hNew=addNfpCeilComp(hN,latency,slRate,isSingle)
    if isSingle
        hNew=transformnfp.getSingleCeilComp(hN,latency,slRate);
    else
        hNew=transformnfp.getDoubleCeilComp(hN,latency,slRate);
    end
end
