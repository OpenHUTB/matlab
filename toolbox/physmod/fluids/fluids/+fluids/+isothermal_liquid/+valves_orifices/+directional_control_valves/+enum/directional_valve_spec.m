classdef directional_valve_spec<int32





    enumeration
        linear(1)
        table1D_area_opening(2)
        table2D_volflow_opening_pressure(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('linear')='Linear - Area vs. spool travel';
            map('table1D_area_opening')='Tabulated data - Area vs. spool travel';
            map('table2D_volflow_opening_pressure')='Tabulated data - Volumetric flow rate vs. spool travel and pressure drop';
        end
    end
end

