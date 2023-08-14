classdef dog_clutch_model<int32




    enumeration
        clutch(1)
        backlash(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('clutch')='physmod:sdl:library:enum:FrictionClutch';
            map('backlash')='physmod:sdl:library:enum:DynamicBacklash';
        end
    end
end
