function blkInfo=getFilterBlkInfo(this,blockInfo)





    filterBank=dsphdlsupport.internal.AbstractFilterBank;
    blkInfo.XILINX_MAXOUTPUT_WORDLENGTH=blockInfo.XILINX_MAXOUTPUT_WORDLENGTH;
    blkInfo.ALTERA_MAXOUTPUT_WORDLENGTH=blockInfo.ALTERA_MAXOUTPUT_WORDLENGTH;
    blkInfo.DELAYLINELIMIT2MAP2RAM=blockInfo.DELAYLINELIMIT2MAP2RAM;
    blkInfo.Numerator=blockInfo.Numerator;
    blkInfo.inMode=blockInfo.inMode;
    blkInfo.NumFrequencyBands=blockInfo.NumFrequencyBands;
    blkInfo.FilterStructure=blockInfo.FilterStructure;
    blkInfo.ComplexMultiplication='Use 4 multipliers and 2 adders';
    if strcmpi(blkInfo.FilterStructure,'Direct form systolic')
        blkInfo.FilterCoefficient=(flipud(...
        filterBank.reshapeFilterCoef(blockInfo.FilterCoefficient,blockInfo.NumFrequencyBands)));
    else
        blkInfo.FilterCoefficient=fliplr(flipud(...
        filterBank.reshapeFilterCoef(blockInfo.FilterCoefficient,blockInfo.NumFrequencyBands)));%#ok<FLUDLR> 
    end
    blkInfo.FilterCoefficientSource='Property';
    blkInfo.RoundingMethod=blockInfo.RoundingMethod;
    blkInfo.OverflowAction=blockInfo.OverflowAction;
    blkInfo.CoefficientsDataType=resolveCoeffDT(this,blockInfo.CoefficientsDataType,...
    blockInfo);
    blkInfo.FilterOutputDataType='Full precision';
    blkInfo.OutputCast=filterBank.resolveFilterDT(...
    resolveFiltDT(this,blockInfo.OutputDataType,blockInfo));


    hIFFT=dsphdl.IFFT('Normalize',blockInfo.Normalize,...
    'FFTLength',blockInfo.NumFrequencyBands,'RoundingMethod',blockInfo.RoundingMethod);
    IFFTOut_DT=getOutputDT(hIFFT,blockInfo.CompiledInputDT);

    blkInfo.CompiledInputDT=IFFTOut_DT;
    blkInfo.inResetSS=0;
    blkInfo.HDLGlobalReset=0;

end

function resolvedDT=resolveCoeffDT(this,unResolvedDT,hBlock)
    if isnumerictype(unResolvedDT)
        resolvedDT=unResolvedDT;





    elseif strcmpi(unResolvedDT,'Same word length as input')
        unResolvedDT=hBlock.CompiledInputDT;
        var=fi(hBlock.FilterCoefficient,any(hBlock.FilterCoefficient<0)...
        ||any(real(hBlock.FilterCoefficient)<0)||any(imag(hBlock.FilterCoefficient)<0)...
        ,unResolvedDT.WordLength);
        if strcmpi(var.Signedness,'Signed')
            resolvedDT=numerictype(1,var.WordLength,var.FractionLength);
        else
            resolvedDT=numerictype(0,var.WordLength,var.FractionLength);
        end
    else
        resolvedDT=unResolvedDT;

    end
end

function resolvedDT=resolveFiltDT(this,unResolvedDT,hBlock)
    if isnumerictype(unResolvedDT)
        if strcmpi(unResolvedDT.Signedness,'Signed')
            resolvedDT=numerictype(1,unResolvedDT.WordLength,unResolvedDT.FractionLength);
        else
            resolvedDT=numerictype(0,unResolvedDT.WordLength,unResolvedDT.FractionLength);
        end
    elseif strcmpi(unResolvedDT,'Same as input')
        var=hBlock.CompiledInputDT;
        if strcmpi(var.Signedness,'Signed')
            resolvedDT=numerictype(1,var.WordLength,var.FractionLength);
        else
            resolvedDT=numerictype(0,var.WordLength,var.FractionLength);
        end
    else
        resolvedDT=unResolvedDT;
    end
end
