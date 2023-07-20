classdef FanParameterization<int32




    enumeration
        Nominal(1)
        Table1D(2)
        Table2DPressure(3)
        Table2DFlowRate(4)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Nominal')='Static pressure and flow rate at reference shaft speed';
            map('Table1D')='1D tabulated data - static pressure vs. flow rate at reference shaft speed';
            map('Table2DPressure')='2D tabulated data - static pressure vs. shaft speed and flow rate';
            map('Table2DFlowRate')='2D tabulated data - flow rate vs. shaft speed and static pressure';
        end
    end
end
