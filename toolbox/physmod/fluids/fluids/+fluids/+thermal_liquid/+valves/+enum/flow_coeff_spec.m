classdef flow_coeff_spec<int32





    enumeration
        cv(1)
        kv(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('cv')='Cv coefficient (USG/min)';
            map('kv')='Kv coefficient (m^3/h)';
        end
    end
end
