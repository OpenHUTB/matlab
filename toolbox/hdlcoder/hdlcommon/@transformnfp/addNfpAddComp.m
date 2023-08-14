function hNew=addNfpAddComp(hN,latency,slRate,isSingle,isHalf)



    if isSingle
        hNew=transformnfp.getSingleAddComp(hN,latency,slRate);
    elseif isHalf
        hNew=transformnfp.getHalfAddComp(hN,latency,slRate);
    else
        hNew=transformnfp.getDoubleAddComp(hN,latency,slRate);
    end
end
