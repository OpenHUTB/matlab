classdef pilot_actuator_type<int32




    enumeration
        single_acting(1)
        double_acting(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('single_acting')='Single-acting';
            map('double_acting')='Double-acting';
        end
    end
end