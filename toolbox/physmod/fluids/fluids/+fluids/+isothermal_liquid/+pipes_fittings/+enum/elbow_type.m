classdef elbow_type<int32




    enumeration
        smooth(1)
        sharp(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('smooth')='Smoothly curved';
            map('sharp')='Sharp-edged (Miter)';
        end
    end
end