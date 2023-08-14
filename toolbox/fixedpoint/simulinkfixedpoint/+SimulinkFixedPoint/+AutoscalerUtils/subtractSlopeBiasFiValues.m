function differenceOfValues=subtractSlopeBiasFiValues(value1,value2)








    fiMath=fimath(...
    'SumMode','SpecifyPrecision',...
    'SumWordLength',value1.WordLength,...
    'SumSlope',value1.Slope,...
    'SumBias',0);
    differenceOfValues=removefimath(setfimath(value1,fiMath)-setfimath(value2,fiMath));
end
