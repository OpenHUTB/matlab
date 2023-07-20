function success=identifyStringWithEval(this,dataTypeString)









    success=false;
    if startsWith(dataTypeString,'fixdt(')
        try
            [numericType,scaledDouble]=eval(dataTypeString);
            success=identifyNumericTypeObject(this,numericType,scaledDouble);
        catch
        end
    elseif startsWith(dataTypeString,'numerictype(')||...
        startsWith(dataTypeString,'slDataTypeAndScale(')
        try
            numericType=eval(dataTypeString);
            success=identifyNumericTypeObject(this,numericType,numericType.isscaleddouble);
        catch
        end
    end
end
