classdef actuator_two_pos_ic<int32





    enumeration
        retracted(0)
        extended(1)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('retracted')='Retracted';
            map('extended')='Extended';
        end
    end
end