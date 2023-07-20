function blkInfo=getIFFTBlkInfo(this,inputSize,blockInfo)




    blkInfo.inMode=blockInfo.inMode;
    blkInfo.BitReversedInput=false;



    blkInfo.outMode=[false;false];






    blkInfo.BitReversedOutput=false;




    blkInfo.Architecture='Streaming Radix 2^2';
    blkInfo.ComplexMultiplication=blockInfo.ComplexMultiplication;
    blkInfo.FFTLength=blockInfo.NumFrequencyBands;

    blkInfo.RoundingMethod=blockInfo.RoundingMethod;
    blkInfo.OverflowAction='Wrap';
    blkInfo.Normalize=blockInfo.Normalize;

    blkInfo.inverseFFT=true;

    blkInfo.inResetSS=0;

    if blkInfo.Normalize
        blkInfo.BitGrowthVector=zeros(log2(blkInfo.FFTLength),1);
    else
        blkInfo.BitGrowthVector=ones(log2(blkInfo.FFTLength),1);
    end
    blkInfo.resetnone=false;

