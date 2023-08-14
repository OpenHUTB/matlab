classdef thermalNetworkTopology<int32





    enumeration
        junctionCase(1)
        cauer(4)
        foster(2)
        external(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('junctionCase')='physmod:ee:library:comments:enum:thermalNetworkTopology:map_JunctionCase';
            map('cauer')='physmod:ee:library:comments:enum:thermalNetworkTopology:map_Cauer';
            map('foster')='physmod:ee:library:comments:enum:thermalNetworkTopology:map_Foster';
            map('external')='physmod:ee:library:comments:enum:thermalNetworkTopology:map_External';
        end
    end
end
