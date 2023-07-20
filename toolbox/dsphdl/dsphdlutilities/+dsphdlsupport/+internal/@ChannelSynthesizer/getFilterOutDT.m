function[filterInDT,filterOutDT,OutputCastDT]=getFilterOutDT(this,blockInfo)




    hIFFT=dsphdl.IFFT('Normalize',blockInfo.Normalize,...
    'FFTLength',blockInfo.NumFrequencyBands,'RoundingMethod',blockInfo.RoundingMethod);
    IFFTOut_DT=getOutputDT(hIFFT,blockInfo.CompiledInputDT);
    filterInDT=pir_fixpt_t(IFFTOut_DT.SignednessBool,IFFTOut_DT.WordLength,-IFFTOut_DT.FractionLength);

    blkInfo=getFilterBlkInfo(this,blockInfo);
    hFIR=dsphdl.private.AbstractFilterBank('FilterStructure',blkInfo.FilterStructure,...
    'CoefficientsDataType',blkInfo.CoefficientsDataType,...
    'FilterOutputDataType','Full precision',...
    'FilterCoefficients',blkInfo.FilterCoefficient);

    OutputDT=getOutputDT(hFIR,IFFTOut_DT);
    filterOutDT=pir_fixpt_t(OutputDT.SignednessBool,...
    OutputDT.WordLength,-OutputDT.FractionLength);
    if isnumerictype(blkInfo.OutputCast)
        dt=blkInfo.OutputCast;
        OutputCastDT=pir_fixpt_t(dt.SignednessBool,...
        dt.WordLength,-dt.FractionLength);
    else
        OutputCastDT=filterOutDT;
    end
    release(hIFFT);
    delete(hIFFT);
    release(hFIR);
    delete(hFIR);
end