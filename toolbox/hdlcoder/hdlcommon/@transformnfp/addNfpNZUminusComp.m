function hNew=addNfpNZUminusComp(hN,uniqNtwkName,slRate,isSingle,isHalf)

    if isHalf
        hNew=transformnfp.getHalfNZUminusComp(hN,uniqNtwkName,slRate);
    elseif isSingle
        hNew=transformnfp.getSingleNZUminusComp(hN,uniqNtwkName,slRate);
    else
        hNew=transformnfp.getDoubleNZUminusComp(hN,uniqNtwkName,slRate);
    end
end
