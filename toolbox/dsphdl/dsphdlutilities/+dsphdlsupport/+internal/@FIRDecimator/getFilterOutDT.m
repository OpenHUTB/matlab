function[filterInDT,filterOutDT]=getFilterOutDT(this,blockInfo)




    hFIR=dsphdl.private.AbstractFilterBank('FilterStructure','Direct form transposed',...
    'CoefficientsDataType',blockInfo.CoefficientsDataType,...
    'FilterOutputDataType','Full precision',...
    'FilterCoefficients',blockInfo.Numerator);

    inputDT=getInputDT(hFIR,blockInfo.CompiledInputDT);
    CoefficientDT=getCoefficientsDT(hFIR,inputDT);
    [fullPrecision,inputPrecision]=dsp.internal.FIRFilterPrecision(cast(hFIR.FilterCoefficients,'like',CoefficientDT),inputDT);

    filterInDT=pir_fixpt_t(inputDT.SignednessBool,inputDT.WordLength,-inputDT.FractionLength);
    filterOutDT=pir_fixpt_t(fullPrecision.Signed,fullPrecision.WordLength,-fullPrecision.FractionLength);

    release(hFIR);
    delete(hFIR);
end
