classdef magic_tire_model<int32




    enumeration
        peak(1)
        constant(2)
        load(3)
        PS(4)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('peak')='physmod:sdl:library:enum:MagicTirePeak';
            map('constant')='physmod:sdl:library:enum:MagicTireConstant';
            map('load')='physmod:sdl:library:enum:MagicTireLoad';
            map('PS')='physmod:sdl:library:enum:MagicTirePS';
        end
    end
end
