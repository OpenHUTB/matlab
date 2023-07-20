classdef(Sealed)InRangeValidator<FunctionApproximation.internal.utilities.ValidatorInterface






    methods(Access=?FunctionApproximation.internal.AbstractUtils)
        function this=InRangeValidator()
        end
    end

    methods
        function success=validate(~,values,dataType)
            range=fixed.internal.type.finiteRepresentableRange(dataType);
            if fixed.internal.type.isAnyFloat(dataType)


                success=all(values>=double(-range(2)))...
                &&all(values<=double(range(2)));
            else


                success=all(values>=double(range(1)))...
                &&all(values<=double(range(2)));
            end
        end
    end
end
