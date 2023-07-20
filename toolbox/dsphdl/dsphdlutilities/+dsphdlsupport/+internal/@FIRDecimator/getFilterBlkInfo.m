function blkInfo=getFilterBlkInfo(this,blockInfo)





    filterBank=dsphdlsupport.internal.AbstractFilterBank;
    blkInfo.XILINX_MAXOUTPUT_WORDLENGTH=blockInfo.XILINX_MAXOUTPUT_WORDLENGTH;
    blkInfo.ALTERA_MAXOUTPUT_WORDLENGTH=blockInfo.ALTERA_MAXOUTPUT_WORDLENGTH;
    blkInfo.DELAYLINELIMIT2MAP2RAM=blockInfo.DELAYLINELIMIT2MAP2RAM;
    blkInfo.Numerator=blockInfo.Numerator;
    blkInfo.inMode=blockInfo.inMode;
    blkInfo.NumFrequencyBands=blockInfo.DecimationFactor;
    blkInfo.FilterStructure=blockInfo.FilterStructure;
    blkInfo.ComplexMultiplication='Use 4 multipliers and 2 adders';
    if strcmpi(blockInfo.FilterStructure,'Direct form transposed')

        blkInfo.FilterCoefficient=fliplr(filterBank.reshapeFilterCoef(blockInfo.Numerator,blockInfo.DecimationFactor));%#ok<FLUDLR>
    else

        blkInfo.FilterCoefficient=filterBank.reshapeFilterCoef(blockInfo.Numerator,blockInfo.DecimationFactor);
    end
    blkInfo.FilterCoefficientSource='Property';
    blkInfo.RoundingMethod=blockInfo.RoundingMethod;
    blkInfo.OverflowAction=blockInfo.OverflowAction;
    blkInfo.CoefficientsDataType=blockInfo.CoefficientsDataType;
    blkInfo.FilterOutputDataType='Full Precision';
    blkInfo.CompiledInputDT=blockInfo.CompiledInputDT;
    blkInfo.inResetSS=0;
    blkInfo.HDLGlobalReset=blockInfo.HDLGlobalReset;

end
