function hNew=addNfpFloat2Fixed(hN,latency,slRate,WL,UWL,FL,rndMode,satMode,flGtZero,isSingle,isHalf)




    if isSingle
        hNew=transformnfp.getConvertSingle2Fixed(hN,latency,slRate,WL,UWL,FL,rndMode,satMode,flGtZero);
    elseif isHalf
        hNew=transformnfp.getConvertHalf2Fixed(hN,slRate,WL,UWL,FL,rndMode,satMode,flGtZero);
    else
        hNew=transformnfp.getConvertDouble2Fixed(hN,latency,slRate,WL,UWL,FL,rndMode,satMode,flGtZero);
    end
end
