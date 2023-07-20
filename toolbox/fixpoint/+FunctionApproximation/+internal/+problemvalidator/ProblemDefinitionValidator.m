classdef ProblemDefinitionValidator<matlab.mixin.Heterogeneous&handle





    properties(Abstract)
ErrorID
    end

    methods(Abstract)
        isValid=validate(this,problemDefinition);
    end

    methods(Sealed)
        function throwError(this,problemDefinition)
            diagnostic=getDiagnostic(this,problemDefinition);
            if~isempty(diagnostic)
                FunctionApproximation.internal.DisplayUtils.throwError(diagnostic);
            end
        end
    end

    methods
        function diagnostic=getDiagnostic(this,problemDefinition)%#ok<INUSD>
            diagnostic=MException.empty;
            if~isempty(this.ErrorID)
                diagnostic=MException(message(this.ErrorID));
            end
        end
    end
end
