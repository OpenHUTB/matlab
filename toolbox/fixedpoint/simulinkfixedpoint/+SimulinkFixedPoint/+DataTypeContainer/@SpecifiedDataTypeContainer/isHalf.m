function flag=isHalf(this)






    flag=false;
    if this.containerType==SimulinkFixedPoint.AutoscalerDataTypes.FloatingPoint
        flag=ishalf(this.evaluatedNumericType);
    end
end
