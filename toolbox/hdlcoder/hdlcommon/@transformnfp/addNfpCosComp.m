function hNew=addNfpCosComp(hN,latency,slRate,argReduction,partMultOpt,isSingle,isHalf)


    denormal=transformnfp.handleDenormal();
    if isSingle
        if argReduction
            hNew=transformnfp.getSingleSinOrCosComp(hN,false,partMultOpt,slRate);
        else
            hNew=transformnfp.getSingleSinOrCosCompArgReduce(hN,false,partMultOpt,slRate);
        end
    elseif isHalf
        hNew=transformnfp.getHalfCosComp(hN,latency,slRate,denormal);
    else
        hNew=transformnfp.getDoubleCosComp(hN,slRate);
    end

end