function hNew=addNfpRelopComp(hN,opName,latency,slRate,isSingle,isHalf)


    if isHalf
        hNew=transformnfp.getHalfRelopComp(hN,opName,latency,slRate);
    elseif isSingle
        hNew=transformnfp.getSingleRelopComp(hN,opName,latency,slRate);
    else
        hNew=transformnfp.getDoubleRelopComp(hN,opName,latency,slRate);
    end
end
