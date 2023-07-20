classdef seedInitialization<int32




    enumeration
        NotRepeatable(1)
        Repeatable(2)
        SpecifySeed(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('NotRepeatable')='physmod:sdl:library:enum:NotRepeatable';
            map('Repeatable')='physmod:sdl:library:enum:Repeatable';
            map('SpecifySeed')='physmod:sdl:library:enum:SpecifySeed';
        end
    end
end
