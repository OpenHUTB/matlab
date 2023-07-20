function hNew=addNfpGainPow2Comp(hN,latency,slRate,isSingle,isHalf)

    if isHalf
        hNew=transformnfp.getHalfGainPow2Comp(hN,latency,slRate);
    elseif isSingle
        hNew=transformnfp.getSingleGainPow2Comp(hN,latency,slRate);
    else
        hNew=transformnfp.getDoubleGainPow2Comp(hN,latency,slRate);
    end
end
