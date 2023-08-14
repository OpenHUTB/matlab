classdef PistonMeasurementSpec<int32




    enumeration
        FromA(1)
        FromZero(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('FromA')='From Piston initial distance from port A';
            map('FromZero')='From zero';
        end
    end
end