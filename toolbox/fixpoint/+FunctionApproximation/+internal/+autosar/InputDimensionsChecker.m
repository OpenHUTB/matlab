classdef InputDimensionsChecker<FunctionApproximation.internal.autosar.AUTOSARLUTComplianceChecker





    methods(Access=public)
        function diagnostic=check(~,context)
            diagnostic=MException.empty();
            if~(context.NumInputs<3)
                diagnostic(end+1)=MException(message('SimulinkFixedPoint:functionApproximation:autosarDimensionCompliance'));
            end
        end
    end
end