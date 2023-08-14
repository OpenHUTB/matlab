function hNew=addNfpMinMaxComp(hN,slRate,isSingle)
    if isSingle
        hNew=transformnfp.getSingleMinMaxComp(hN,slRate);
    else
        hNew=transformnfp.getDoubleMinMaxComp(hN,slRate);
    end
end
