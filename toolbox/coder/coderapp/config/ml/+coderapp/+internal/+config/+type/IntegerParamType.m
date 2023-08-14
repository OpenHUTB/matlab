classdef(Sealed)IntegerParamType<coderapp.internal.config.type.AbstractNumericParamType



    methods
        function this=IntegerParamType()
            this@coderapp.internal.config.type.AbstractNumericParamType('int',...
            'coderapp.internal.config.data.IntegerParamData','int64');
        end
    end
end

