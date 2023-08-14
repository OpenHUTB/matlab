classdef tireIC<int32




    enumeration
        slipping(0)
        traction(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('slipping')='physmod:sdl:library:enum:TireSlipping';
            map('traction')='physmod:sdl:library:enum:TireTraction';
        end
    end
end
