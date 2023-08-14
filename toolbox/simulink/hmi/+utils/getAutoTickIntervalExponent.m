

function tickIntervalExp=getAutoTickIntervalExponent(min,max)







    expRange=floor(log10(max/min));
    tickIntervalExp=ceil(expRange/25);
end