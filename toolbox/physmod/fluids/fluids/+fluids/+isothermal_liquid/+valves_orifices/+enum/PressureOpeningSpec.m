classdef PressureOpeningSpec<int32





    enumeration
        Linear(1)
        TabulatedArea(2)
        TabulatedVolumetricFlow(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Linear')='Linear - Area vs. pressure';
            map('TabulatedArea')='Tabulated data - Area vs. pressure';
            map('TabulatedVolumetricFlow')='Tabulated data - Volumetric flow rate vs. pressure';
        end
    end
end