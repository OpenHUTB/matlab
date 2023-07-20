classdef(Sealed)ModelOpenValidator<FunctionApproximation.internal.utilities.ValidatorInterface




    methods(Access=?FunctionApproximation.internal.AbstractUtils)

        function this=ModelOpenValidator()
        end
    end

    methods
        function success=validate(~)

            success=~isempty(find_system('Type','block_diagram'));
        end
    end
end
