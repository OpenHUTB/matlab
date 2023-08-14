classdef ironloss<int32



    enumeration
        none(0)
        tabulated2D(2)
        tabulated3D(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('none')='physmod:ee:library:comments:enum:srm:ironloss:map_None';
            map('tabulated2D')='physmod:ee:library:comments:enum:srm:ironloss:map_Tabulated2D';
            map('tabulated3D')='physmod:ee:library:comments:enum:srm:ironloss:map_Tabulated3D';
        end
    end
end

