classdef tableType<int32




    enumeration
        IfMat(1)
        VfMat(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('IfMat')='physmod:ee:library:comments:enum:mosfet:tableType:map_TableInIfForm';
            map('VfMat')='physmod:ee:library:comments:enum:mosfet:tableType:map_TableInVfForm';
        end
    end
end
