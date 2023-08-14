classdef BallValveSpec<int32




    enumeration
        Standard(1)
        Tabulated(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Standard')='Area of overlapping circles';
            map('Tabulated')='Tabulated data';
        end
    end
end