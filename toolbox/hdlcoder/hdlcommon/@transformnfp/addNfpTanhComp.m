function hNew=addNfpTanhComp(hN,slRate,isSingle)



    if isSingle
        hNew=transformnfp.getSingleTanhComp(hN,slRate);
    else
        hNew=transformnfp.getDoubleTanhComp(hN,slRate);
    end

end