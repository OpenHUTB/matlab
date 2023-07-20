classdef(Sealed)DoubleArrayParamType<coderapp.internal.config.type.AbstractNumericParamType



    methods
        function this=DoubleArrayParamType()
            this@coderapp.internal.config.type.AbstractNumericParamType('double[]',...
            'coderapp.internal.config.data.DoubleArrayParamData','double');
        end
    end
end

