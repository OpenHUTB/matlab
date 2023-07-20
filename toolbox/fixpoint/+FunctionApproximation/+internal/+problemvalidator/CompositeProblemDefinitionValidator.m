classdef CompositeProblemDefinitionValidator<FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator







    properties(Abstract)
        ValidationExpression function_handle
    end

    properties(SetAccess=protected)
        ChildValidators(1,:)FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator
        ChildValidationFlag(1,:)logical
    end

    methods
        function isValid=validate(this,problemDefinition)


            for iChild=1:numel(this.ChildValidators)
                this.ChildValidationFlag(iChild)=validate(this.ChildValidators(iChild),problemDefinition);
            end
            isValid=this.ValidationExpression(this.ChildValidationFlag);
        end
    end

    methods
        function diagnostic=getDiagnostic(this,problemDefinition)
            diagnostic=MException(message(this.ErrorID));
            diagnostic=addChildDiagnostic(this,problemDefinition,diagnostic,this.ChildValidationFlag);
        end
    end

    methods(Sealed,Access=protected)
        function diagnostic=addChildDiagnostic(this,problemDefinition,diagnostic,childValidity)
            for iChild=1:numel(childValidity)
                if~childValidity(iChild)
                    diagnostic=diagnostic.addCause(getDiagnostic(this.ChildValidators(iChild),problemDefinition));
                end
            end
        end
    end
end
