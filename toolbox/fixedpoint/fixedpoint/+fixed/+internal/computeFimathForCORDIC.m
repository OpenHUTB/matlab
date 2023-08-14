function localFimath=computeFimathForCORDIC(valueWithThetaNumType,ioWordLength,ioFracLength)







    localFimath=valueWithThetaNumType.fimath;
    localFimath.ProductMode='FullPrecision';
    localFimath.SumMode='SpecifyPrecision';
    localFimath.SumWordLength=ioWordLength;
    localFimath.SumFractionLength=ioFracLength;
    localFimath.CastBeforeSum=true;
    localFimath.RoundMode='floor';
    localFimath.OverflowMode='wrap';


