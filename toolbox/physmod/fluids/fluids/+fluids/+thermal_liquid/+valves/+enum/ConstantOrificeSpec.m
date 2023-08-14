classdef ConstantOrificeSpec<int32





    enumeration
        Area(1)
        Table1DVolFlowPressure(2)
        Table1DMassFlowPressure(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Area')='Orifice area';
            map('Table1DVolFlowPressure')='Tabulated data - Volumetric flow rate vs. pressure drop';
            map('Table1DMassFlowPressure')='Tabulated data - Mass flow rate vs. pressure drop';
        end
    end
end
