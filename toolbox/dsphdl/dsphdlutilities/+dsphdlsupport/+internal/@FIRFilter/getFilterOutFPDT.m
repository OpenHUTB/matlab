function[filterInDT,filterOutDT]=getFilterOutFPDT(this,blockInfo)



    coeff=reshape(blockInfo.FilterCoefficient,1,[]);
    hFIR=dsphdl.private.AbstractFilterBank('FilterStructure','Direct form transposed',...
    'CoefficientsDataType',blockInfo.CoefficientsDataType,...
    'FilterOutputDataType','Full precision',...
    'FilterCoefficients',coeff);

    inputDT=getInputDT(hFIR,blockInfo.CompiledInputDT);
    if strcmpi(blockInfo.FilterCoefficientSource,'property')
        CoefficientDT=getCoefficientsDT(hFIR,inputDT);
        [fullPrecision,inputPrecision]=dsp.internal.FIRFilterPrecision(cast(hFIR.FilterCoefficients,'like',CoefficientDT),inputDT);
    else
        CoefficientDT=blockInfo.CoefficientsDataType;
        fullPrecision.Signed=1;
        fullPrecision.WordLength=inputDT.WordLength+CoefficientDT.WordLength+ceil(log2(length(coeff)));
        fullPrecision.FractionLength=CoefficientDT.FractionLength+inputDT.FractionLength;
    end

    filterInDT=pir_fixpt_t(inputDT.SignednessBool,inputDT.WordLength,-inputDT.FractionLength);
    filterOutDT=pir_fixpt_t(fullPrecision.Signed,fullPrecision.WordLength,-fullPrecision.FractionLength);

    release(hFIR);
    delete(hFIR);
end
