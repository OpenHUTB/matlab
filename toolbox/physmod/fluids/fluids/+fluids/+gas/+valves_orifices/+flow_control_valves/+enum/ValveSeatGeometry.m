classdef ValveSeatGeometry<int32





    enumeration
        Sharp(1)
        Conical(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Sharp')='Sharp-edged';
            map('Conical')='Conical';
        end
    end
end