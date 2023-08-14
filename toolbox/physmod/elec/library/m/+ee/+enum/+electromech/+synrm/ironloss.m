classdef ironloss<int32



    enumeration
        specifyRm(1)
        steinmetz2D(2)
        tabulated3D(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('specifyRm')='physmod:ee:library:comments:enum:electromech:synrm:ironloss:map_SpecifyRm';
            map('steinmetz2D')='physmod:ee:library:comments:enum:electromech:synrm:ironloss:map_Steinmetz2D';
            map('tabulated3D')='physmod:ee:library:comments:enum:electromech:synrm:ironloss:map_Tabulated3D';
        end
    end
end

