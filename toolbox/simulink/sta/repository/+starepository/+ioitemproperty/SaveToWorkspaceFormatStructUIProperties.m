classdef SaveToWorkspaceFormatStructUIProperties<starepository.ioitemproperty.ItemUIProperties




    properties(Constant,Hidden)
        NormalIcon='variable_struct.png';
        ErrorIcon='variable_struct_error.png';

        WarningIcon='variable_struct_warning.png';
    end

    methods
        function obj=SaveToWorkspaceFormatStructUIProperties
            obj=obj@starepository.ioitemproperty.ItemUIProperties;
        end

    end

end

