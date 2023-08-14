classdef fidelity<int32



    enumeration
        idealSwitch(1)
        includeChargeDyn(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('idealSwitch')='physmod:ee:library:comments:enum:diode:fidelity:map_IdealSwitch';
            map('includeChargeDyn')='physmod:ee:library:comments:enum:diode:fidelity:map_IncludeChargeDyn';
        end
    end
end
