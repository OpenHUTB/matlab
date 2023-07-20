classdef PropertySchema<handle





    properties(Access=public)
        DataType(1,:)char;
        AllowedValues(1,:)cell;
        HasDynamicAllowedValues(1,1)logical=true;
        IsPlatformSpecificProp(1,1)logical;
    end

    methods(Access=public)
        function this=PropertySchema(dataType,allowedValues,hasDynamicAllowedValues,isPlatformSpecificProp)
            if strcmp(dataType,'edit')

                dataType='string';
            end
            this.DataType=dataType;
            this.AllowedValues=allowedValues;
            this.HasDynamicAllowedValues=hasDynamicAllowedValues;
            this.IsPlatformSpecificProp=isPlatformSpecificProp;
        end
    end
end
