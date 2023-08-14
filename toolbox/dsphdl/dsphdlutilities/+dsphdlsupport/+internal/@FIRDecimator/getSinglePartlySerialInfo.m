function blkInfo=getSinglePartlySerialInfo(this,blockInfo)





    blkInfo=blockInfo;

    blkInfo.FilterStructure='Partly serial systolic';

    blkInfo.SharingFactor=blockInfo.NumCycles;
    blkInfo.FilterCoefficient=blockInfo.Numerator;


    blkInfo.SerializationOption='Minimum number of cycles between valid input samples';
    blkInfo.NumeratorSource='Property';


    blkInfo.FilterOutputDataType=blockInfo.OutputDataType;
    blkInfo.CompiledInputSize=1;
    blkInfo.inResetSS=0;

end
