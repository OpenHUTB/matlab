function hNew=addNfpSinhComp(hN,slRate,isSingle)



    if isSingle
        hNew=transformnfp.getSingleSinhComp(hN,slRate);
    else
        hNew=transformnfp.getDoubleSinhComp(hN,slRate);
    end

end