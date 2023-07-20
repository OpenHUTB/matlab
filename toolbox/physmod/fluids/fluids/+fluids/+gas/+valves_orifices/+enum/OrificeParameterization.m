classdef OrificeParameterization<int32




    enumeration
        Cv(1)
        Kv(2)
        SonicConductance(3)
        Area(4)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Cv')='Cv flow coefficient';
            map('Kv')='Kv flow coefficient';
            map('SonicConductance')='Sonic conductance';
            map('Area')='Orifice area';
        end
    end
end