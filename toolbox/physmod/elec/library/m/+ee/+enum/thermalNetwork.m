classdef thermalNetwork<int32




    enumeration
        timeconstant(1)
        thermalmass(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('timeconstant')='physmod:ee:library:comments:enum:thermalNetwork:map_ByThermalTimeConstants';
            map('thermalmass')='physmod:ee:library:comments:enum:thermalNetwork:map_ByThermalMass';
        end
    end
end
