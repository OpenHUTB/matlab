classdef pwm_or_av<int32



    enumeration
        pwm(1)
        averaged(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('pwm')='physmod:ee:library:comments:enum:pwm_or_av:map_PWM';
            map('averaged')='physmod:ee:library:comments:enum:pwm_or_av:map_Averaged';
        end
    end
end