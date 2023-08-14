classdef(Sealed)ProblemHDLOptimizedModeValidator<FunctionApproximation.internal.utilities.ValidatorInterface





    methods(Access=?FunctionApproximation.internal.AbstractUtils)
        function this=ProblemHDLOptimizedModeValidator()
        end
    end

    methods
        function success=validate(this,problemDefinition)
            diagnosticsVector=MException.empty();
            if problemDefinition.NumberOfInputs>1
                diagnosticsVector(end+1)=MException(message('SimulinkFixedPoint:functionApproximation:hdlNumberOfInputsMustBeOne'));
            end
            if~ismember(problemDefinition.Options.Interpolation,["Flat","Linear"])
                diagnosticsVector(end+1)=MException(message('SimulinkFixedPoint:functionApproximation:hdlInterpolationMustBeFlatOrNearest'));
            end
            if problemDefinition.Options.AUTOSARCompliant
                diagnosticsVector(end+1)=MException(message('SimulinkFixedPoint:functionApproximation:hdlNotCompatibleWithAUTOSAR'));
            end
            parentID='SimulinkFixedPoint:functionApproximation:hdlOptimizedModeIssues';
            this.Diagnostic=FunctionApproximation.internal.autosar.getCompleteDiagnostic(diagnosticsVector,parentID);
            success=isempty(this.Diagnostic);
        end
    end
end