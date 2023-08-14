classdef cartridge_actuator_num_port<int32




    enumeration
        three(1)
        four(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('three')='3';
            map('four')='4';
        end
    end
end