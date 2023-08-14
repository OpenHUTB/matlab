function hNew=addNfpSignumComp(hN,slRate,isSingle)
    if isSingle
        hNew=transformnfp.getSingleSignumComp(hN,slRate);
    else
        hNew=transformnfp.getDoubleSignumComp(hN,slRate);
    end
end
