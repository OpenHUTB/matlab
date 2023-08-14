classdef parameterization<int32
    enumeration
        direct(1)
        ratedpower(2)
    end
    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('direct')='physmod:ee:library:comments:enum:rlc:parameterization:map_SpecifyComponentValuesDirectly';
            map('ratedpower')='physmod:ee:library:comments:enum:rlc:parameterization:map_SpecifyByRatedPower';
        end
    end
end
