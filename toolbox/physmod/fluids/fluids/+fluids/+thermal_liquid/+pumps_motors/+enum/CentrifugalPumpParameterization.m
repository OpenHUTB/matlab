classdef CentrifugalPumpParameterization<int32





    enumeration
        Nominal(1)
        Table1D(2)
        Table2D(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Nominal')='Capacity, head, and brake power at reference shaft speed';
            map('Table1D')='1D tabulated data - head and brake power vs. capacity at reference shaft speed';
            map('Table2D')='2D tabulated data - head and brake power vs. capacity and shaft speed';
        end
    end
end