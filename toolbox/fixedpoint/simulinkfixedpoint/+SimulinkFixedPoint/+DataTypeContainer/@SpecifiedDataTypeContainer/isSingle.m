function flag=isSingle(this)






    flag=false;
    if this.containerType==SimulinkFixedPoint.AutoscalerDataTypes.FloatingPoint
        flag=this.evaluatedNumericType.issingle;
    end
end
