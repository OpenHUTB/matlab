function nfpOptions=getBlockInfo(this,~)


    nfpOptions=getNFPBlockInfo(this);


    nfpRadixStr=getImplParams(this,'DivisionAlgorithm');
    if isempty(nfpRadixStr)||contains(nfpRadixStr,'2')
        nfpOptions.Radix=int32(2);
    else
        nfpOptions.Radix=int32(4);
    end
end
