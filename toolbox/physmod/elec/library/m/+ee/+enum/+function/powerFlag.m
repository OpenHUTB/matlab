classdef powerFlag<int32



    enumeration
        origin(0)
        hyp(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('origin')='physmod:ee:library:comments:enum:function:powerFlag:map_SymmetricWithRespectToOrigin';
            map('hyp')='physmod:ee:library:comments:enum:function:powerFlag:map_HypFunctionPositiveProtection';
        end
    end
end