classdef(Sealed)ProblemAUTOSARComplianceValidator<FunctionApproximation.internal.utilities.ValidatorInterface





    methods(Access=?FunctionApproximation.internal.AbstractUtils)
        function this=ProblemAUTOSARComplianceValidator()
        end
    end

    methods
        function success=validate(this,problemDefinition)
            context=FunctionApproximation.internal.autosar.getLUTComplianceContext(problemDefinition);
            checkers=[...
            FunctionApproximation.internal.autosar.InputDimensionsChecker(),...
            FunctionApproximation.internal.autosar.InputTypesChecker(),...
            FunctionApproximation.internal.autosar.AUTOSARRoutineChecker(),...
            FunctionApproximation.internal.autosar.InterpolationModeChecker(),...
            FunctionApproximation.internal.autosar.BreakpointSpecificationModeChecker()...
            ];
            diagnosticsVector=MException.empty();
            for iCheck=1:numel(checkers)
                diagnostic=checkers(iCheck).check(context);
                diagnosticsVector=[diagnosticsVector,diagnostic];%#ok<AGROW>
            end
            parentID='SimulinkFixedPoint:functionApproximation:autosarCompliance';
            this.Diagnostic=FunctionApproximation.internal.autosar.getCompleteDiagnostic(diagnosticsVector,parentID);
            success=isempty(this.Diagnostic);
        end
    end
end