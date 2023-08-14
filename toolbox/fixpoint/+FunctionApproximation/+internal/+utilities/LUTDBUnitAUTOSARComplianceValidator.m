classdef(Sealed)LUTDBUnitAUTOSARComplianceValidator<FunctionApproximation.internal.utilities.ValidatorInterface





    methods(Access=?FunctionApproximation.internal.AbstractUtils)
        function this=LUTDBUnitAUTOSARComplianceValidator()
        end
    end

    methods
        function success=validate(this,lutDBUnit)
            context=FunctionApproximation.internal.autosar.getLUTComplianceContextFromLUTDBUnit(lutDBUnit);
            checkers=[...
            FunctionApproximation.internal.autosar.InputDimensionsChecker(),...
            FunctionApproximation.internal.autosar.InputTypesChecker(),...
            FunctionApproximation.internal.autosar.AUTOSARRoutineChecker(),...
            FunctionApproximation.internal.autosar.InterpolationModeChecker(),...
            FunctionApproximation.internal.autosar.BreakpointSpecificationModeChecker(),...
            FunctionApproximation.internal.autosar.StorageTypesChecker(),...
            ];
            diagnosticsVector=MException.empty();
            for iCheck=1:numel(checkers)
                diagnostic=checkers(iCheck).check(context);
                diagnosticsVector=[diagnosticsVector,diagnostic];%#ok<AGROW>
            end
            parentID='SimulinkFixedPoint:functionApproximation:autosarComplianceLUTDBUnit';
            this.Diagnostic=FunctionApproximation.internal.autosar.getCompleteDiagnostic(diagnosticsVector,parentID);
            success=isempty(this.Diagnostic);
        end
    end
end