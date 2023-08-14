classdef DisplacementSpecification<int32






    enumeration
        Displacement(1)
        FlowSpeed(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Displacement')='Volumetric displacement';
            map('FlowSpeed')='Nominal mass flow rate and shaft speed';
        end
    end
end