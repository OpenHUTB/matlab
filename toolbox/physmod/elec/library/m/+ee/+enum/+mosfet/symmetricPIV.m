classdef symmetricPIV<int32



    enumeration
        no(0)
        yes(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('no')='physmod:ee:library:comments:enum:mosfet:symmetricPIV:map_provideNegativeAndPositiveVsdData';
            map('yes')='physmod:ee:library:comments:enum:mosfet:symmetricPIV:map_providePositiveVsdDataOnly';
        end
    end
end