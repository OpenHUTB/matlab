classdef(Sealed)QuantizedEqualsOriginalValidator<FunctionApproximation.internal.utilities.ValidatorInterface





    methods(Access=?FunctionApproximation.internal.AbstractUtils)
        function this=QuantizedEqualsOriginalValidator()
        end
    end

    methods
        function success=validate(~,value,dataType)
            quantizedValue=double(fixed.internal.math.castUniversal(value,dataType));
            success=~any(value-quantizedValue);
        end
    end
end
