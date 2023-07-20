function hNew=addNfpRecipComp(hN,latency,slRate,isSingle,isHalf)
    denormal=transformnfp.handleDenormal();
    if isSingle
        hNew=transformnfp.getSingleRecipComp(hN,latency,slRate,denormal);
    elseif isHalf
        hNew=transformnfp.getHalfRecipComp(hN,latency,slRate,denormal);
    else
        hNew=transformnfp.getDoubleRecipComp(hN,latency,slRate);
    end
end
