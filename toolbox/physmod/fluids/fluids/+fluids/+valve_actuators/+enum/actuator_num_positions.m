classdef actuator_num_positions<int32





    enumeration
        two(2)
        three(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('two')='2';
            map('three')='3';
        end
    end
end