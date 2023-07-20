classdef fluxTabulationOption<int32
    enumeration
        DQcartesian(1)
        DQpolar(2)
        Acartesian(3)
        Apolar(4)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('DQcartesian')='physmod:ee:library:comments:enum:fem_motor:fluxTabulationOption:map_DQcartesian';
            map('DQpolar')='physmod:ee:library:comments:enum:fem_motor:fluxTabulationOption:map_DQpolar';
            map('Acartesian')='physmod:ee:library:comments:enum:fem_motor:fluxTabulationOption:map_Acartesian';
            map('Apolar')='physmod:ee:library:comments:enum:fem_motor:fluxTabulationOption:map_Apolar';
        end
    end
end