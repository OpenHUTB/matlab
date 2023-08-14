function u=unionRange(a,b)






    u=SimulinkFixedPoint.safeConcat(a,b);


    [minVal,maxVal]=SimulinkFixedPoint.extractMinMax(u);


    u=[minVal,maxVal];
end
