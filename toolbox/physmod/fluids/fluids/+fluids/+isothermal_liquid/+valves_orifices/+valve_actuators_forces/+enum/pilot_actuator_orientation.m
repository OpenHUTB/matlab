classdef pilot_actuator_orientation<int32





    enumeration
        positive(1)
        negative(-1)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('positive')='Pilot pressure at port X causes positive piston displacement';
            map('negative')='Pilot pressure at port X causes negative piston displacement';
        end
    end
end