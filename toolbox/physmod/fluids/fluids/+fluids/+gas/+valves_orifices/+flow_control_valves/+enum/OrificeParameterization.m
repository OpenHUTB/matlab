classdef OrificeParameterization<int32





    enumeration
        Geometry(1)
        Cv(2)
        Kv(3)
        SonicConductance(4)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Geometry')='Orifice area based on geometry';
            map('Cv')='Cv flow coefficient';
            map('Kv')='Kv flow coefficient';
            map('SonicConductance')='Sonic conductance';
        end
    end
end