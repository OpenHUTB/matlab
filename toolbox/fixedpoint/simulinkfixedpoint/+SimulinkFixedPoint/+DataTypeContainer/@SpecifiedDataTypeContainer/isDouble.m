function flag=isDouble(this)






    flag=false;
    if this.containerType==SimulinkFixedPoint.AutoscalerDataTypes.FloatingPoint
        flag=this.evaluatedNumericType.isdouble;
    end
end
