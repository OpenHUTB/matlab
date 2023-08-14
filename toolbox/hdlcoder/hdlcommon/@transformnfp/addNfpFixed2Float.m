function hNew=addNfpFixed2Float(hN,latency,slRate,WL,UWL,FL,isSingle,isHalf)




    if isSingle
        hNew=transformnfp.getConvertFixed2Single(hN,latency,slRate,WL,UWL,FL);
    elseif isHalf
        hNew=transformnfp.getConvertFixed2Half(hN,slRate,WL,UWL,FL);
    else
        hNew=transformnfp.getConvertFixed2Double(hN,latency,slRate,WL,UWL,FL);
    end
end
