classdef engineType<int32

    enumeration
        SI(1)
        diesel(2)
        Generic(3)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('SI')='physmod:sdl:library:enum:SparkIgnition';
            map('diesel')='physmod:sdl:library:enum:Diesel';
            map('Generic')='physmod:sdl:library:enum:Generic';
        end
    end
end
