function hNew=addNfpFloorComp(hN,latency,slRate,isSingle)
    if isSingle
        hNew=transformnfp.getSingleFloorComp(hN,latency,slRate);
    else
        hNew=transformnfp.getDoubleFloorComp(hN,latency,slRate);
    end
end
