function hNew=addNfpASinComp(hN,slRate,isSingle)
    if isSingle
        hNew=transformnfp.getSingleASinComp(hN,slRate);
    else
        hNew=transformnfp.getDoubleASinComp(hN,slRate);
    end
end
