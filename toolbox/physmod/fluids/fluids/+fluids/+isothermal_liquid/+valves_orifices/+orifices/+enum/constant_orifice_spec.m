classdef constant_orifice_spec<int32





    enumeration
        area(1)
        table1D_volflow_pressure(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('area')='Orifice area';
            map('table1D_volflow_pressure')='Tabulated data - Volumetric flow rate vs. pressure drop';
        end
    end
end
