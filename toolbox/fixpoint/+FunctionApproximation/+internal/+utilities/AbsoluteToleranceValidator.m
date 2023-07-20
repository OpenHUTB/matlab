classdef(Sealed)AbsoluteToleranceValidator<FunctionApproximation.internal.utilities.ValidatorInterface





    methods(Access=?FunctionApproximation.internal.AbstractUtils)
        function this=AbsoluteToleranceValidator()
        end
    end

    methods
        function success=validate(~,dataType,absoluteTolerance,toleranceCalculator)

            success=isnumeric(absoluteTolerance)&&absoluteTolerance>0;
            if success


                minTolerance=toleranceCalculator.getTolerance(dataType);
                success=absoluteTolerance>=minTolerance;
            end
        end
    end
end
