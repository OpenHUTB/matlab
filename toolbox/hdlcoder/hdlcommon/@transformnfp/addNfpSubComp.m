function hNew=addNfpSubComp(hN,latency,slRate,isSingle,isHalf)



    if isSingle
        hNew=transformnfp.getSingleSubComp(hN,latency,slRate);
    elseif isHalf
        hNew=transformnfp.getHalfSubComp(hN,latency,slRate);
    else
        hNew=transformnfp.getDoubleSubComp(hN,latency,slRate);
    end
end
