classdef switchModelVoltage<int32



    enumeration
        resistance(1)
        transition(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('resistance')='physmod:ee:library:comments:enum:switches:switchModelVoltage:map_SmoothTransitionBetweenVonAndVoff';
            map('transition')='physmod:ee:library:comments:enum:switches:switchModelVoltage:map_AbruptTransitionAfterDelay';
        end
    end
end