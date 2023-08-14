classdef dcparam_option<int32



    enumeration
        circuit_param(1)
        torque_speed(2)
        load_speed(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('circuit_param')='physmod:ee:library:comments:enum:dcparam_option:circuit_param';
            map('torque_speed')='physmod:ee:library:comments:enum:dcparam_option:torque_speed';
            map('load_speed')='physmod:ee:library:comments:enum:dcparam_option:load_speed';
        end
    end
end

