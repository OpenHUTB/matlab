classdef switchModel<int32



    enumeration
        resistance(1)
        transition(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('resistance')='physmod:ee:library:comments:enum:switches:switchModel:map_SmoothTransitionBetweenIonAndIoff';
            map('transition')='physmod:ee:library:comments:enum:switches:switchModel:map_AbruptTransitionAfterDelay';
        end
    end
end