classdef symmetricNIV<int32



    enumeration
        no(0)
        yes(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('no')='physmod:ee:library:comments:enum:mosfet:symmetricNIV:map_provideNegativeAndPositiveVdsData';
            map('yes')='physmod:ee:library:comments:enum:mosfet:symmetricNIV:map_providePositiveVdsDataOnly';
        end
    end
end