classdef envelope<int32



    enumeration






        torque_power(2)
        tabulated(1)
        tabulated2D(3)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('torque_power')='physmod:ee:library:comments:enum:electromech:envelope:map_TorquePower';
            map('tabulated')='physmod:ee:library:comments:enum:electromech:envelope:map_Tabulated';
            map('tabulated2D')='physmod:ee:library:comments:enum:electromech:envelope:map_Tabulated2D';
        end
    end
end