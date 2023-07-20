classdef(Sealed)WordLengthValidator<FunctionApproximation.internal.utilities.ValidatorInterface





    methods(Access=?FunctionApproximation.internal.AbstractUtils)
        function this=WordLengthValidator()
        end
    end

    methods
        function success=validate(~,wordLengthVector,modelName)

            try
                modelObject=get_param(modelName,'Object');
                success=~isempty(modelObject);
            catch
                success=false;
            end

            if success




                hardwareConstraint=SimulinkFixedPoint.AutoscalerConstraints.HardwareConstraintFactory.getConstraint(modelName);
                success=all(ismember(wordLengthVector,hardwareConstraint.ChildConstraint.SpecificWL));
            end
        end
    end
end
