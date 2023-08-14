classdef friction_model_var<int32




    enumeration
        fixed(1)
        TLU(2)
        PS(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('fixed')='physmod:sdl:library:enum:FixedKineticFriction';
            map('TLU')='physmod:sdl:library:enum:TLUKineticFriction';
            map('PS')='physmod:sdl:library:enum:PSFriction';
        end
    end
end
