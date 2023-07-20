classdef InputTypesChecker<FunctionApproximation.internal.autosar.AUTOSARLUTComplianceChecker





    methods(Access=public)
        function diagnostic=check(~,context)
            diagnostic=MException.empty();
            if~context.AllInputsSame
                diagnostic(end+1)=MException(message('SimulinkFixedPoint:functionApproximation:autosarInputTypesMustBeSameCompliance'));
            end
        end
    end
end