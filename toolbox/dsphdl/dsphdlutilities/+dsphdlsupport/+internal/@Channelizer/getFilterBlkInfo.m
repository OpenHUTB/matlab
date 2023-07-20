function blkInfo=getFilterBlkInfo(this,blockInfo)





    filterBank=dsphdlsupport.internal.AbstractFilterBank;
    blkInfo.XILINX_MAXOUTPUT_WORDLENGTH=blockInfo.XILINX_MAXOUTPUT_WORDLENGTH;
    blkInfo.ALTERA_MAXOUTPUT_WORDLENGTH=blockInfo.ALTERA_MAXOUTPUT_WORDLENGTH;
    blkInfo.DELAYLINELIMIT2MAP2RAM=blockInfo.DELAYLINELIMIT2MAP2RAM;

    blkInfo.inMode=blockInfo.inMode;
    blkInfo.NumFrequencyBands=blockInfo.NumFrequencyBands;

    blkInfo.FilterStructure=blockInfo.FilterStructure;
    blkInfo.ComplexMultiplication='Use 4 multipliers and 2 adders';
    blkInfo.FilterCoefficient=fliplr(filterBank.reshapeFilterCoef(blockInfo.FilterCoefficient,blockInfo.NumFrequencyBands));
    if strcmpi(blkInfo.FilterStructure,'Direct form systolic')
        blkInfo.FilterCoefficient=((...
        filterBank.reshapeFilterCoef(blockInfo.FilterCoefficient,blockInfo.NumFrequencyBands)));
    else
        blkInfo.FilterCoefficient=fliplr((...
        filterBank.reshapeFilterCoef(blockInfo.FilterCoefficient,blockInfo.NumFrequencyBands)));
    end
    blkInfo.Numerator=blkInfo.FilterCoefficient;
    blkInfo.FilterCoefficientSource='Property';
    blkInfo.RoundingMethod=blockInfo.RoundingMethod;
    blkInfo.OverflowAction=blockInfo.OverflowAction;
    blkInfo.CoefficientsDataType=blockInfo.CoefficientsDataType;
    blkInfo.FilterOutputDataType=filterBank.resolveFilterDT(blockInfo.FilterOutputDataType);
    blkInfo.CompiledInputDT=blockInfo.CompiledInputDT;
    blkInfo.inResetSS=0;
    blkInfo.HDLGlobalReset=0;

end
