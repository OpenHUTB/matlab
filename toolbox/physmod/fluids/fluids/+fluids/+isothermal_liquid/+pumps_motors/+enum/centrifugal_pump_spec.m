classdef centrifugal_pump_spec<int32





    enumeration
        nominal(1)
        table1D(2)
        table2D(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('nominal')='Capacity, head, and brake power at reference shaft speed';
            map('table1D')='1D tabulated data - head and brake power vs. capacity at reference shaft speed';
            map('table2D')='2D tabulated data - head and brake power vs. capacity and shaft speed';
        end
    end
end