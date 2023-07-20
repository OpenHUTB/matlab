classdef spool_orifice<int32




    enumeration
        round_hole(1)
        rectangle_slot(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('round_hole')='Round holes';
            map('rectangle_slot')='Rectangular slot';
        end
    end
end
