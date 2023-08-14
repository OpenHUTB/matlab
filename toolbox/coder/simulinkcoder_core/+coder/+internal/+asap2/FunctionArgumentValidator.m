classdef FunctionArgumentValidator<handle




    methods(Static,Access=public)
        function isValidArg=validateLogicalScalar(input)



            isValidArg=isscalar(input)&&...
            (islogical(input)||...
            (isnumeric(input)&&~isnan(input)));
        end
    end

end

