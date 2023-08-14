function jsReturnFormattedValue=jsEvalin(workspace,inExpression)







    try
        outVal=evalin(workspace,inExpression);
    catch ME
        throwAsCaller(ME)
    end

    jsReturnFormattedValue=outVal;
    if isscalar(outVal)&&isnumeric(outVal)

        jsReturnFormattedValue=qualifyNumeric(outVal);

    else

        if~isstring(outVal)

            ANY_NAN=any(isnan(outVal));
            ANY_INF=any(isinf(outVal));

            if ANY_NAN||ANY_INF

                cellReturn=cell(1,length(outVal));

                for k=1:length(outVal)
                    cellReturn{k}=qualifyNumeric(outVal(k));
                end

                jsReturnFormattedValue=cellReturn;
            end
        else
            jsReturnFormattedValue=char(outVal);
        end
    end

end

function returnVal=qualifyNumeric(inVal)
    returnVal=slwebwidgets.sanitizeNumericForJS(inVal);
end