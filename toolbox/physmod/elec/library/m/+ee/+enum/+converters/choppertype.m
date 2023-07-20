classdef choppertype<int32



    enumeration
        firstquadrant(1)
        secondquadrant(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('firstquadrant')='physmod:ee:library:comments:enum:converters:choppertype:map_ClassAFirstQuadrant';
            map('secondquadrant')='physmod:ee:library:comments:enum:converters:choppertype:map_ClassBSecondQuadrant';
        end
    end
end
