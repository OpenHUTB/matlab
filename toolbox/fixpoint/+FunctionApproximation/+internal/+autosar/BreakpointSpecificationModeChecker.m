classdef BreakpointSpecificationModeChecker<FunctionApproximation.internal.autosar.AUTOSARLUTComplianceChecker





    methods(Access=public)
        function diagnostic=check(~,context)
            diagnostic=MException.empty();
            if context.IFXMode
                if(context.BreakpointSpecification.isEvenSpacing()&&~context.AllTypesSame)
                    diagnostic(end+1)=MException(message('SimulinkFixedPoint:functionApproximation:autosarEvenSpacingAllTypesMustBeSameCompliance'));
                end
            elseif context.IFLMode
                if context.BreakpointSpecification.isEvenSpacing()
                    diagnostic(end+1)=MException(message('SimulinkFixedPoint:functionApproximation:autosarIFLExplicitValuesCompliance'));
                end
            end


        end
    end
end


