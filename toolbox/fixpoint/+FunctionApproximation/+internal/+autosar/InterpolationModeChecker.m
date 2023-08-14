classdef InterpolationModeChecker<FunctionApproximation.internal.autosar.AUTOSARLUTComplianceChecker





    methods(Access=public)
        function diagnostic=check(~,context)
            diagnostic=MException.empty();
            if context.IFXMode
                if context.NumInputs==1
                    if~any(context.Interpolation==["Linear","Flat"])
                        diagnostic(end+1)=MException(message('SimulinkFixedPoint:functionApproximation:autosarInterpolationCompliance1DIFX'));
                    end
                else
                    if~any(context.Interpolation==["Linear","Flat","Nearest"])
                        diagnostic(end+1)=MException(message('SimulinkFixedPoint:functionApproximation:autosarInterpolationCompliance2DIFX'));
                    end
                end
            end

            if context.IFLMode
                if~(context.Interpolation=="Linear")
                    diagnostic(end+1)=MException(message('SimulinkFixedPoint:functionApproximation:autosarInterpolationComplianceIFL'));
                end
            end
        end
    end
end


