classdef ProblemForMATLABLUTValidator<FunctionApproximation.internal.utilities.ValidatorInterface





    methods(Access=?FunctionApproximation.internal.AbstractUtils)
        function this=ProblemForMATLABLUTValidator()
        end
    end

    methods
        function success=validate(this,problemDefinition)
            diagnosticsVector=MException.empty();

            if problemDefinition.Options.Interpolation==FunctionApproximation.InterpolationMethod.None
                diagnosticsVector(end+1)=MException(message('SimulinkFixedPoint:functionApproximation:mlutDirectInterpolationNotSupported'));
            end

            if problemDefinition.Options.AUTOSARCompliant
                diagnosticsVector(end+1)=MException(message('SimulinkFixedPoint:functionApproximation:mlutNotCompatibleWithAUTOSAR'));
            end

            if problemDefinition.Options.UseParallel
                diagnosticsVector(end+1)=MException(message('SimulinkFixedPoint:functionApproximation:mlutUseParallelNotSupported'));
            end

            if problemDefinition.Options.HDLOptimized
                diagnosticsVector(end+1)=MException(message('SimulinkFixedPoint:functionApproximation:mlutHDLOptimizedNotSupported'));
            end

            parentID='SimulinkFixedPoint:functionApproximation:mlutIssues';
            this.Diagnostic=FunctionApproximation.internal.autosar.getCompleteDiagnostic(diagnosticsVector,parentID);
            success=isempty(this.Diagnostic);
        end
    end
end
