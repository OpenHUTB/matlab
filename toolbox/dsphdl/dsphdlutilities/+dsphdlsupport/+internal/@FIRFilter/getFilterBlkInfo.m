function blkInfo=getFilterBlkInfo(this,blockInfo)





    filterBank=dsphdlsupport.internal.AbstractFilterBank;
    blkInfo.XILINX_MAXOUTPUT_WORDLENGTH=blockInfo.XILINX_MAXOUTPUT_WORDLENGTH;
    blkInfo.ALTERA_MAXOUTPUT_WORDLENGTH=blockInfo.ALTERA_MAXOUTPUT_WORDLENGTH;
    blkInfo.DELAYLINELIMIT2MAP2RAM=blockInfo.DELAYLINELIMIT2MAP2RAM;

    blkInfo.inMode=[1,1];
    blkInfo.ResetInputPort=blockInfo.ResetInputPort;
    blkInfo.HDLGlobalReset=blockInfo.HDLGlobalReset;
    blkInfo.FrameSize=blockInfo.CompiledInputSize;
    blkInfo.FilterStructure=blockInfo.FilterStructure;
    blkInfo.Numerator=blockInfo.Numerator;
    blkInfo.SymmetryOptimization=blockInfo.SymmetryOptimization;
    if strcmpi(blockInfo.NumeratorSource,'Input port (Parallel Interface)')
        if isempty(blockInfo.Numerator)


            coefLen=blockInfo.CompiledCoefInputSize;
            blkInfo.CoefficientsComplexity=blockInfo.CoefficientsComplexity;
            if blockInfo.CoefficientsComplexity
                blkInfo.FilterCoefficient=complex(rand(1,blockInfo.CompiledCoefInputSize),rand(1,blockInfo.CompiledCoefInputSize));
            else
                blkInfo.FilterCoefficient=rand(1,blockInfo.CompiledCoefInputSize);
            end
        else
            blkInfo.FilterCoefficient=blockInfo.Numerator;
        end
    else
        blkInfo.FilterCoefficient=blockInfo.Numerator;
    end

    if strcmpi(blkInfo.FilterStructure,'Direct form transposed')
        if blockInfo.CompiledInputSize==1
            blkInfo.FilterCoefficient=fliplr(filterBank.reshapeFilterCoef(blkInfo.FilterCoefficient,blkInfo.FrameSize));
        else
            coeff=fliplr(filterBank.reshapeFilterCoef(blkInfo.FilterCoefficient,blkInfo.FrameSize));
            blkInfo.FilterCoefficient=[coeff(end,:);coeff(1:end-1,:)];
        end
    else
        if blockInfo.CompiledInputSize==1
            blkInfo.FilterCoefficient=filterBank.reshapeFilterCoef(blkInfo.FilterCoefficient,blkInfo.FrameSize);
        else
            coeff=filterBank.reshapeFilterCoef(blkInfo.FilterCoefficient,blkInfo.FrameSize);
            blkInfo.FilterCoefficient=[coeff(end,:);coeff(1:end-1,:)];
        end
    end
    blkInfo.ComplexMultiplication='Use 4 multipliers and 2 adders';
    blkInfo.FilterCoefficientSource=blockInfo.NumeratorSource;
    blkInfo.RoundingMethod=blockInfo.RoundingMethod;
    blkInfo.OverflowAction=blockInfo.OverflowAction;
    blkInfo.CoefficientsDataType=blockInfo.CoefficientsDataType;
    blkInfo.FilterOutputDataType=filterBank.resolveFilterDT(blockInfo.OutputDataType);
    blkInfo.CompiledInputDT=blockInfo.CompiledInputDT;
    blkInfo.CompiledInputSize=blockInfo.CompiledInputSize;
    blkInfo.inResetSS=0;
end
