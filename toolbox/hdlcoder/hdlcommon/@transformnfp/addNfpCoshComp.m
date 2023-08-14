function hNew=addNfpCoshComp(hN,slRate,isSingle)



    if isSingle
        hNew=transformnfp.getSingleCoshComp(hN,slRate);
    else
        hNew=transformnfp.getDoubleCoshComp(hN,slRate);
    end

end