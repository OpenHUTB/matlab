classdef SaveToWorkspaceFormatArrayUIProperties<starepository.ioitemproperty.ItemUIProperties





    properties(Constant,Hidden)
        NormalIcon='variable_matrix.png';
        ErrorIcon='variable_matrix_error.png';

        WarningIcon='variable_matrix_warning.png';
    end

    methods
        function obj=SaveToWorkspaceFormatArrayUIProperties
            obj=obj@starepository.ioitemproperty.ItemUIProperties;
        end

    end

end
