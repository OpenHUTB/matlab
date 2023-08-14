function hNew=addNfpSinComp(hN,latency,slRate,argReduction,partMultOpt,isSingle,isHalf)


    denormal=transformnfp.handleDenormal();
    if isSingle
        if argReduction
            hNew=transformnfp.getSingleSinOrCosComp(hN,true,partMultOpt,slRate);
        else
            hNew=transformnfp.getSingleSinOrCosCompArgReduce(hN,true,partMultOpt,slRate);
        end
    elseif isHalf
        hNew=transformnfp.getHalfSinComp(hN,latency,slRate,denormal);
    else
        hNew=transformnfp.getDoubleSinComp(hN,slRate);
    end

end
