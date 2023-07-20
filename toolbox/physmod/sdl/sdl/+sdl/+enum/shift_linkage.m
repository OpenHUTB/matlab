classdef shift_linkage<int32




    enumeration
        PS(1)
        conserving(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('PS')='physmod:sdl:library:enum:PS';
            map('conserving')='physmod:sdl:library:enum:Conserving';
        end
    end
end
