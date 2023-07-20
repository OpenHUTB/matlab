classdef ThermostaticExpansionValveParameterization<int32





    enumeration
        Nominal(1)
        Tabulated(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Nominal')='Nominal capacity, superheat, and operating conditions';
            map('Tabulated')='Tabulated data - quadrant diagram';
        end
    end
end