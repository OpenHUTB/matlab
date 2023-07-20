classdef reverseRecoveryModel<int32





    enumeration
        fixed(1)
        tabulated2d(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('fixed')='physmod:ee:library:comments:enum:diode:reverseRecoveryModel:map_Fixed';
            map('tabulated2d')='physmod:ee:library:comments:enum:diode:reverseRecoveryModel:map_Tabulated2d';
        end
    end
end
