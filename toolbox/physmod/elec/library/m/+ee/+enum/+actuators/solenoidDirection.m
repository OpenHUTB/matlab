classdef solenoidDirection<int32




    enumeration
        away(1)
        towards(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('away')='physmod:ee:library:comments:enum:actuators:solenoidDirection:map_away';
            map('towards')='physmod:ee:library:comments:enum:actuators:solenoidDirection:map_towards';
        end
    end
end