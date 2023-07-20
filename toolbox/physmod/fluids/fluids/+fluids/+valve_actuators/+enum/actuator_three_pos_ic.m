classdef actuator_three_pos_ic<int32





    enumeration
        extended_negative(-1)
        neutral(0)
        extended_positive(1)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('extended_negative')='Extended negative';
            map('neutral')='Neutral';
            map('extended_positive')='Extended positive';
        end
    end
end