classdef cartridge_actuator_orientation<int32





    enumeration
        positive(1)
        negative(-1)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('positive')='Positive displacement opens valve';
            map('negative')='Negative displacement opens valve';
        end
    end
end