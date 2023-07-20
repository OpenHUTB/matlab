function blkInfo=getFIRPartlySerialBlkInfo(this,blockInfo)





    filterBank=dsphdlsupport.internal.AbstractFilterBank;
    blkInfo=blockInfo;

    blkInfo.FilterStructure='Partly serial systolic';
    sFactor=blockInfo.NumCycles;












    blkInfo.SharingFactor=sFactor*blockInfo.DecimationFactor;
    blkInfo.FilterCoefficient=flipud(filterBank.reshapeFilterCoef(blockInfo.Numerator,blockInfo.DecimationFactor));


    blkInfo.SerializationOption='Minimum number of cycles between valid input samples';
    blkInfo.NumeratorSource='Property';
    blkInfo.FilterOutputDataType='Full Precision';
    blkInfo.CompiledInputSize=1;
    blkInfo.inResetSS=0;

end
