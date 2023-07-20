function hNew=addNfpATanComp(hN,slRate,isSingle)
    if isSingle
        hNew=transformnfp.getSingleATanComp(hN,slRate);
    else
        hNew=transformnfp.getDoubleATanComp(hN,slRate);
    end
end
