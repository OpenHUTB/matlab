classdef FlowCoefficientSpec<int32




    enumeration
        Kv(1)
        Cv(2)
        CdArea(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Kv')='Kv coefficient (SI)';
            map('Cv')='Cv coefficient (USCS)';
            map('CdArea')='Cd coefficient and area';
        end
    end
end