classdef ElbowType<int32




    enumeration
        Smooth(1)
        Sharp(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Smooth')='Smoothly curved';
            map('Sharp')='Sharp-edged (Miter)';
        end
    end
end