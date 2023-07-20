classdef DataSetUIProperties<starepository.ioitemproperty.ItemUIProperties




    properties(Constant,Hidden)
        NormalIcon='variable_object.png';
        ErrorIcon='variable_object_error.png';

        WarningIcon='variable_object_warning.png';
    end

    methods
        function obj=DataSetUIProperties
            obj=obj@starepository.ioitemproperty.ItemUIProperties;
        end

    end

end

