function firblockInfo=getFIRFilterblockInfo(this,firdecimblockInfo,ii,dataIn)%#ok<INUSL>







    firblockInfo=firdecimblockInfo;
    decimFactor=firdecimblockInfo.DecimationFactor;
    firblockInfo.DecimationFactor=1;


    firblockInfo.Numerator=firdecimblockInfo.Numerator(decimFactor-ii+1:decimFactor:end);
    firblockInfo.NumeratorQuantized=firdecimblockInfo.NumeratorQuantized(decimFactor-ii+1:decimFactor:end);


    firblockInfo.CoefficientsDataType=numerictype(firblockInfo.NumeratorQuantized);

    firblockInfo.OutputDataType='Full precision';
    firblockInfo.CompiledInputSize=dataIn.Type.Dimensions;
    firblockInfo.NumeratorSource='Property';



    firblockInfo.SymmetryOptimization=false;

end
