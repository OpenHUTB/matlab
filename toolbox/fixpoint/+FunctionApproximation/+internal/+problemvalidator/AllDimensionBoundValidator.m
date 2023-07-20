classdef(Sealed)AllDimensionBoundValidator<FunctionApproximation.internal.problemvalidator.CompositeProblemDefinitionValidator






    properties
        ErrorID='SimulinkFixedPoint:functionApproximation:issuesWhileSettingBounds'
        ValidationExpression=@(x)all(x);
    end

    properties(SetAccess=private)
        DataBase FunctionApproximation.internal.problemvalidator.DimensionSpecificValidationDataBase;
    end

    methods
        function this=AllDimensionBoundValidator()
            this.ChildValidators=[...
            FunctionApproximation.internal.problemvalidator.FixedPointDataTypeBoundValidator(),...
            FunctionApproximation.internal.problemvalidator.FloatingPointDataTypeLowerBoundValidator(),...
            FunctionApproximation.internal.problemvalidator.FloatingPointDataTypeUpperBoundValidator(),...
            FunctionApproximation.internal.problemvalidator.UpperBoundGreaterThanLowerBound(),...
            ];
        end
    end

    methods
        function isValid=validate(this,problemDefinition)
            this.DataBase=FunctionApproximation.internal.problemvalidator.DimensionSpecificValidationDataBase();
            for iDim=1:problemDefinition.NumberOfInputs
                context=FunctionApproximation.internal.problemvalidator.getDimensionSpecificCheckContext(problemDefinition,iDim);
                success=validate@FunctionApproximation.internal.problemvalidator.CompositeProblemDefinitionValidator(this,context);
                this.DataBase.registerValidity(iDim,success,this.ChildValidationFlag);
            end
            isValid=this.DataBase.areAllValid();
        end
    end

    methods
        function diagnostic=getDiagnostic(this,problemDefinition)
            diagnostic=MException(message(this.ErrorID));
            for iDim=1:problemDefinition.NumberOfInputs
                if~isValidForDim(this.DataBase,iDim)
                    context=FunctionApproximation.internal.problemvalidator.getDimensionSpecificCheckContext(problemDefinition,iDim);
                    diagnostic=addChildDiagnostic(this,context,diagnostic,getChildValidity(this.DataBase,iDim));
                end
            end
        end
    end
end
