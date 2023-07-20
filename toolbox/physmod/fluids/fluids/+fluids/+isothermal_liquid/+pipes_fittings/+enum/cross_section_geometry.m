classdef cross_section_geometry<int32




    enumeration
        circular(1)
        annular(2)
        rectangular(3)
        elliptical(4)
        triangular(5)
        custom(6)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('circular')='Circular';
            map('annular')='Annular';
            map('rectangular')='Rectangular';
            map('elliptical')='Elliptical';
            map('triangular')='Isosceles triangular';
            map('custom')='Custom';
        end
    end
end