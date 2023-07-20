function success=identifyNumericTypeObject(this,numericType,isScaledDouble)





    success=false;

    this.scaledDouble=logical(isScaledDouble);

    if~(fixed.internal.isAnyNumericType(numericType))
        return;
    end


    if numericType.isfloat()
        this.containerType=SimulinkFixedPoint.AutoscalerDataTypes.FloatingPoint;
        success=true;
    elseif numericType.isfixed||numericType.isscaleddouble
        this.containerType=SimulinkFixedPoint.AutoscalerDataTypes.FixedPoint;
        success=true;
    elseif numericType.isboolean
        this.containerType=SimulinkFixedPoint.AutoscalerDataTypes.Boolean;
        success=true;
    elseif numericType.ishalf()



        this.containerType=SimulinkFixedPoint.AutoscalerDataTypes.FloatingPoint;
        success=true;
    end



    if success
        this.evaluatedNumericType=this.getSimulinkNumericType(numericType);
        this.evaluatedDTString=this.getEvalString(this.origDTString);
    end
end
