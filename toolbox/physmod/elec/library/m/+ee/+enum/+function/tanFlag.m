classdef tanFlag<int32



    enumeration
        hyp(0)
        linear(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('hyp')='physmod:ee:library:comments:enum:function:tanFlag:map_HypFunctionPositiveDenominatorProtection';
            map('linear')='physmod:ee:library:comments:enum:function:tanFlag:map_LinearExtrapolationProtection';
        end
    end
end