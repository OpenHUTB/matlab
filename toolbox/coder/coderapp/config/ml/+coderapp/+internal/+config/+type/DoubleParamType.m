classdef(Sealed)DoubleParamType<coderapp.internal.config.type.AbstractNumericParamType



    methods
        function this=DoubleParamType()
            this@coderapp.internal.config.type.AbstractNumericParamType('double',...
            'coderapp.internal.config.data.DoubleParamData','double');
        end
    end
end

