classdef vcoFrequencyDependence<int32





    enumeration
        linear(0)
        tabulated(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('linear')='physmod:ee:library:comments:enum:ic:vcoFrequencyDependence:map_Linear';
            map('tabulated')='physmod:ee:library:comments:enum:ic:vcoFrequencyDependence:map_Tabulated';
        end
    end
end