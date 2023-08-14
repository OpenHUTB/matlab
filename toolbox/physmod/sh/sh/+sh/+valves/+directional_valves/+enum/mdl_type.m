classdef mdl_type<int32




    enumeration
        linear(1)
        table1D_area_opening(2)
        table2D_flowrate_opening_pressure(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('linear')='Maximum area and opening';
            map('table1D_area_opening')='Area vs. opening table';
            map('table2D_flowrate_opening_pressure')='Pressure-flow characteristic';
        end
    end
end