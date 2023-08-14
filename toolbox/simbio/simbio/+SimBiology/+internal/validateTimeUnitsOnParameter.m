function[]=validateTimeUnitsOnParameter(parameterCell,parameterType,baseObjectName,unitConversion)














    for i=1:numel(parameterCell)
        parameterObj=parameterCell{i};
        if isempty(parameterObj)

            continue;
        end

        parameterUnits=parameterObj.ValueUnits;




        if unitConversion&&isempty(parameterUnits)
            throw(createException(parameterType,parameterObj,baseObjectName));
        end



        try
            sbiounitcalculator(parameterUnits,'second',1);
        catch
            if unitConversion
                throw(createException(parameterType,parameterObj,baseObjectName));
            else
                exception=createException(parameterType,parameterObj,baseObjectName);
                warning(exception.identifier,'%s',exception.message);
            end
        end
    end
end

function exception=createException(parameterType,parameterObj,baseObjectName)
    errorId=sprintf('SimBiology:PKModelMapCompile:INVALID_%s_UNITS',upper(parameterType));
    errorMessage=message('SimBiology:PKModelMapCompile:InvalidUnits',...
    parameterObj.PartiallyQualifiedName,parameterType,baseObjectName);
    exception=MException(errorId,getString(errorMessage));
end