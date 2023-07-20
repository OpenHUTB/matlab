classdef opening_spec<int32





    enumeration
        linear(1)
        tabulated(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('linear')='Linear';
            map('tabulated')='Tabulated data';
        end
    end
end