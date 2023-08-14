

function hNew=addNfpHypotComp(hN,slRate,isSingle)
    if isSingle
        hNew=transformnfp.getSingleHypotComp(hN,slRate);
    end
end
