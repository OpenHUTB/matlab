function hNew=addNfpTanComp(hN,slRate,argReduction,isSingle)
    if isSingle
        hNew=transformnfp.getSingleTanComp(hN,argReduction,slRate);
    else
        hNew=transformnfp.getDoubleTanComp(hN,argReduction,slRate);
    end
end
