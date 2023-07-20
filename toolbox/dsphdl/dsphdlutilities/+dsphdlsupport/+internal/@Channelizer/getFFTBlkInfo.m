function blkInfo=getFFTBlkInfo(this,inputSize,blockInfo)




    blkInfo.inMode=blockInfo.inMode;
    blkInfo.BitReversedInput=false;
    if strcmpi(blockInfo.OutputSize,'Same as input size')
        blkInfo.outMode=blockInfo.outMode;
    else
        blkInfo.outMode=[false;false];

    end
    if strcmpi(blockInfo.OutputSize,'Same as input size')
        blkInfo.BitReversedOutput=false;
    else
        if inputSize==blockInfo.NumFrequencyBands
            blkInfo.BitReversedOutput=false;
        else
            blkInfo.BitReversedOutput=true;
        end
    end
    blkInfo.Architecture='Streaming Radix 2^2';
    blkInfo.ComplexMultiplication=blockInfo.ComplexMultiplication;
    blkInfo.FFTLength=blockInfo.NumFrequencyBands;

    blkInfo.RoundingMethod=blockInfo.RoundingMethod;
    blkInfo.OverflowAction='Wrap';
    blkInfo.Normalize=blockInfo.Normalize;

    blkInfo.inverseFFT=false;

    blkInfo.inResetSS=0;

    if blkInfo.Normalize
        blkInfo.BitGrowthVector=zeros(log2(blkInfo.FFTLength),1);
    else
        blkInfo.BitGrowthVector=ones(log2(blkInfo.FFTLength),1);
    end
    blkInfo.resetnone=false;
end
