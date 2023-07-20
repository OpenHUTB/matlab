classdef fidelity<int32




    enumeration
        simplified(1)
        detailed(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('simplified')='physmod:ee:library:comments:enum:fuelcell:fidelity:map_simplified';
            map('detailed')='physmod:ee:library:comments:enum:fuelcell:fidelity:map_detailed';
        end
    end
end