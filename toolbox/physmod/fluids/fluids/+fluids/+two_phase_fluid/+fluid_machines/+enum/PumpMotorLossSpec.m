classdef PumpMotorLossSpec<int32




    enumeration
        Analytical(1)
        TabulatedEfficiency(2)
        TabulatedLosses(3)
        InputEfficiency(4)
        InputLosses(5)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Analytical')='Analytical';
            map('TabulatedEfficiency')='Tabulated data - volumetric and mechanical efficiencies';
            map('TabulatedLosses')='Tabulated data - volumetric and mechanical losses';
            map('InputEfficiency')='Input signal - volumetric and mechanical efficiencies';
            map('InputLosses')='Input signal - volumetric and mechanical losses';
        end
    end
end