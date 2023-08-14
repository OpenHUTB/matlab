classdef tank_volume_spec<int32




    enumeration
        constant(1)
        table(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('constant')='Constant cross-section area';
            map('table')='Tabulated data - volume vs. level';
        end
    end
end