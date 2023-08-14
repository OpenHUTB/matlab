function hNew=addNfpACosComp(hN,slRate,isSingle)
    if isSingle
        hNew=transformnfp.getSingleACosComp(hN,slRate);
    else
        hNew=transformnfp.getDoubleACosComp(hN,slRate);
    end
end
