function hNew=addNfpAbsComp(hN,slRate,isSingle)
    if isSingle
        hNew=transformnfp.getSingleAbsComp(hN,slRate);
    else
        hNew=transformnfp.getDoubleAbsComp(hN,slRate);
    end
end
