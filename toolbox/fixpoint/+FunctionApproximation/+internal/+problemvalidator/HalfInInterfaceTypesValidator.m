classdef(Sealed)HalfInInterfaceTypesValidator<FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator





    properties
        ErrorID='SimulinkFixedPoint:functionApproximation:halfInInterfaceTypes'
    end

    methods
        function isValid=validate(~,problemDefinition)
            interfaceTypes=getInterfaceTypes(problemDefinition);
            anyHalf=any(arrayfun(@(x)fixed.internal.type.isAnyHalf(x),interfaceTypes));
            isValid=true;
            if anyHalf
                isValid=all(arrayfun(@(x)fixed.internal.type.isAnyFloat(x),interfaceTypes));
            end
        end
    end
end
