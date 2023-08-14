function hNew=addNfpDivComp(hN,latency,slRate,isSingle,isHalf)




    if isSingle
        hNew=transformnfp.getSingleDivComp(hN,latency,slRate);
    elseif isHalf
        hNew=transformnfp.getHalfDivComp(hN,latency,slRate);
    else
        hNew=transformnfp.getDoubleDivComp(hN,latency,slRate);
    end
end
