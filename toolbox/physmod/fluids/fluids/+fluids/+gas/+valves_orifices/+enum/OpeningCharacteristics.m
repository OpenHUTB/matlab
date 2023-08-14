classdef OpeningCharacteristics<int32




    enumeration
        Linear(1)
        Tabulated(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Linear')='Linear';
            map('Tabulated')='Tabulated';
        end
    end
end