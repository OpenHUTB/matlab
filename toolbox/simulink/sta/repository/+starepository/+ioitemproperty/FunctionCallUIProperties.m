classdef FunctionCallUIProperties<starepository.ioitemproperty.ItemUIProperties





    properties(Constant,Hidden)
        NormalIcon='variable_function_call.png';
        ErrorIcon='variable_function_call_error.png';

        WarningIcon='variable_function_call_warning.png';
    end

    methods
        function obj=FunctionCallUIProperties
            obj=obj@starepository.ioitemproperty.ItemUIProperties;
        end

    end

end
