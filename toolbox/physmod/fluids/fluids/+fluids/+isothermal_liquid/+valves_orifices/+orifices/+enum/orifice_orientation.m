classdef orifice_orientation<int32




    enumeration
        positive(1)
        negative(-1)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('positive')='Positive control member displacement opens orifice';
            map('negative')='Negative control member displacement opens orifice';
        end
    end
end
