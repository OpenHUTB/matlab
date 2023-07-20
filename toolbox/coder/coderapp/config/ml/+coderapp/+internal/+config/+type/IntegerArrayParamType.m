classdef(Sealed)IntegerArrayParamType<coderapp.internal.config.type.AbstractNumericParamType



    methods
        function this=IntegerArrayParamType()
            this@coderapp.internal.config.type.AbstractNumericParamType('int[]',...
            'coderapp.internal.config.data.IntegerArrayParamData','int64');
        end
    end
end

