function hNew=addNfpSinCosComp(hN,slRate,argReduction,partMultOpt,isSingle)


    if isSingle
        if argReduction
            hNew=transformnfp.getSingleSinCosComp(hN,partMultOpt,slRate);
        else
            hNew=transformnfp.getSingleSinCosCompArgReduce(hN,partMultOpt,slRate);
        end
    else
        if argReduction
            hNew=transformnfp.getDoubleSinCosComp(hN,partMultOpt,slRate);
        else
            hNew=transformnfp.getDoubleSinCosCompArgReduce(hN,partMultOpt,slRate);
        end
    end
