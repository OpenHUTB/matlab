function identifyStringWithResolve(this,DTString,contextObject)



    if startsWith(DTString,'slDataTypeAndScale(')
        DTString(end)=',';
        contextPath=regexprep(contextObject.getFullName,'\n',' ');
        fullStringToEvaluate=sprintf('%s ''%s'')',DTString,contextPath);
        try
            numericType=eval(fullStringToEvaluate);
            identifyNumericTypeObject(this,numericType,false);
        catch
        end
    elseif startsWith(DTString,'fixdt(')



        [numericType,scaledDouble]=slResolve(DTString,contextObject.Handle);
        identifyNumericTypeObject(this,numericType,scaledDouble);
    elseif startsWith(DTString,'numerictype(')
        try
            numericType=slResolve(DTString,contextObject.Handle);
            identifyNumericTypeObject(this,numericType,numericType.isscaleddouble);
        catch
        end
    end
end