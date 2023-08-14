function[filterInDT,filterOutDT]=getFilterOutDT(this,blockInfo)





    filterBank=dsphdlsupport.internal.AbstractFilterBank;
    hFIR=dsphdl.private.AbstractFilterBank('FilterStructure','Direct form transposed',...
    'CoefficientsDataType',blockInfo.CoefficientsDataType,...
    'FilterOutputDataType',filterBank.resolveFilterDT(blockInfo.FilterOutputDataType),...
    'FilterCoefficients',filterBank.reshapeFilterCoef(blockInfo.FilterCoefficient,blockInfo.NumFrequencyBands));

    inputDT=getInputDT(hFIR,blockInfo.CompiledInputDT);

    filterInDT=pir_fixpt_t(inputDT.SignednessBool,inputDT.WordLength,-inputDT.FractionLength);
    filterOutDT=getOutputDT(hFIR,inputDT);
    filterOutDT=pir_fixpt_t(filterOutDT.Signed,filterOutDT.WordLength,-filterOutDT.FractionLength);

    release(hFIR);
    delete(hFIR);
end
