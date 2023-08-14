classdef(Sealed)ModelInfTimeValidator<FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator





    properties
        ErrorID='SimulinkFixedPoint:functionApproximation:infStopTime'
    end

    methods
        function isValid=validate(~,problemDefinition)
            isValid=true;
            if problemDefinition.InputFunctionType=="SubSystem"
                modleName=bdroot(problemDefinition.FunctionToReplace);
                stopTime=slResolve(get_param(modleName,'StopTime'),modleName);
                isValid=~isinf(stopTime);
            end
        end
    end
end