classdef orifice_spec<int32




    enumeration
        linear(1)
        table1D_area_opening(2)
        table2D_volflow_opening_pressure(3)
        table2D_massflow_opening_pressure(4)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('linear')='Linear - Area vs. control member position';
            map('table1D_area_opening')='Tabulated data - Area vs. control member position';
            map('table2D_volflow_opening_pressure')='Tabulated data - Volumetric flow rate vs. control member position and pressure drop';
            map('table2D_massflow_opening_pressure')='Tabulated data - Mass flow rate vs. control member position and pressure drop';

        end
    end
end
