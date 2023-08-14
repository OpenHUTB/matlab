classdef SimulationTimeUtils<handle
    properties(Constant)
        AutoStringLowerCase='auto';
    end


    methods(Static,Access=public)
        function isAuto=isAutoStopTime(stopTimeExpression)
            expressionString=strtrim(stopTimeExpression);
            isAuto=strcmpi(expressionString,Simulink.ModelReference.Conversion.SimulationTimeUtils.AutoStringLowerCase);
        end


        function value=getValueFromGlobalScope(modelName,expressionString,defaultValue)
            if Simulink.ModelReference.Conversion.SimulationTimeUtils.isAutoStopTime(expressionString)
                value=defaultValue;
            else
                value=evalinGlobalScope(modelName,expressionString);
            end
        end
    end
end
