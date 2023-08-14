classdef noiseParameterization<int32





    enumeration
        same(1)
        different(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('same')='physmod:ee:library:comments:enum:ic:noiseParameterization:map_ApplySameDensityFunctionToBothInputs';
            map('different')='physmod:ee:library:comments:enum:ic:noiseParameterization:map_ApplyDifferentDensityFunctionToEachInput';
        end
    end
end