function hNew=addNfpUminusComp(hN,slRate,isSingle,isHalf)

    if isHalf
        hNew=transformnfp.getHalfUminusComp(hN,slRate);
    elseif isSingle
        hNew=transformnfp.getSingleUminusComp(hN,slRate);
    else
        hNew=transformnfp.getDoubleUminusComp(hN,slRate);
    end
end
