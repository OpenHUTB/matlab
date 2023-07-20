function hNew=addNfpTrigComp(hN,slRate,isSingle)
    if isSingle
        hNew=transformnfp.getSingleTrigComp(hN,slRate);
    else
        hNew=transformnfp.getDoubletTrigComp(hN,slRate);
    end
end
