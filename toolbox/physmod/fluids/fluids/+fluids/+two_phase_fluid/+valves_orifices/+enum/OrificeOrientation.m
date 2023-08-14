classdef OrificeOrientation<int32




    enumeration
        Positive(1)
        Negative(-1)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Positive')='Positive control member displacement opens orifice';
            map('Negative')='Negative control member displacement opens orifice';
        end
    end
end
