classdef vol_expansion_spec<int32




    enumeration
        area(1)
        diameter(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('area')='Cross-sectional area vs. pressure';
            map('diameter')='Hydraulic diameter vs. pressure';
        end
    end
end