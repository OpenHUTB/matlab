classdef TubeCrossSection<int32





    enumeration
        Circular(1)
        Rectangular(2)
        Annular(3)
        Generic(4)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Circular')='Circular';
            map('Rectangular')='Rectangular';
            map('Annular')='Annular';
            map('Generic')='Generic';
        end
    end
end