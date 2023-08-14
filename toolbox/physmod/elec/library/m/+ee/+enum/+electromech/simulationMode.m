classdef simulationMode<int32



    enumeration
        stepping(1)
        averaged(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('stepping')='physmod:ee:library:comments:enum:electromech:simulationMode:map_Stepping';
            map('averaged')='physmod:ee:library:comments:enum:electromech:simulationMode:map_Averaged';
        end
    end
end