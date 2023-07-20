classdef timechanging<int32


    enumeration
        constant(1)
        ramp(2)
        step(3)
        modulation(4)
        external(5)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('constant')='physmod:ee:library:comments:enum:timechanging:map_Constant';
            map('ramp')='physmod:ee:library:comments:enum:timechanging:map_Ramp';
            map('step')='physmod:ee:library:comments:enum:timechanging:map_Step';
            map('modulation')='physmod:ee:library:comments:enum:timechanging:map_Modulation';
            map('external')='physmod:ee:library:comments:enum:timechanging:map_External';
        end
    end
end
