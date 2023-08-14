



classdef thermal_liquid_concentration<int32

    enumeration
        volume_fraction(1)
        mass_fraction(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('volume_fraction')='Volume fraction';
            map('mass_fraction')='Mass fraction';
        end
    end

end