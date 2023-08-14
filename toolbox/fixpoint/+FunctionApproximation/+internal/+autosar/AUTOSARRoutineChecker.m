classdef AUTOSARRoutineChecker<FunctionApproximation.internal.autosar.AUTOSARLUTComplianceChecker





    methods(Access=public)
        function diagnostic=check(~,context)
            diagnostic=MException.empty();
            if~(context.IFXMode||context.IFLMode)
                diagnostic(end+1)=MException(message('SimulinkFixedPoint:functionApproximation:autosarTypeCompliance'));
                diagnostic(end+1)=MException(message('SimulinkFixedPoint:functionApproximation:autosarFixedPointWLCompliance'));
            end
        end
    end
end


