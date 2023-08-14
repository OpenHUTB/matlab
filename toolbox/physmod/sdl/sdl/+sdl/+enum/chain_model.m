classdef chain_model<int32




    enumeration
        ideal(1)
        flexible(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('ideal')='physmod:sdl:library:enum:ChainIdeal';
            map('flexible')='physmod:sdl:library:enum:ChainFlexible';
        end
    end
end
