classdef spool_orientation<int32





    enumeration
        positive(1)
        negative(-1)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('positive')='Positive spool displacement opens the orifice';
            map('negative')='Negative spool displacement opens the orifice';
        end
    end
end
