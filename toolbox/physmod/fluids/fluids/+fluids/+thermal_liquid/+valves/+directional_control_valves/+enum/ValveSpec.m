classdef ValveSpec<int32





    enumeration
        Linear(1)
        Table1DAreaOpening(2)
        Table2DVolFlowOpeningPressure(3)
        Table2DMassFlowOpeningPressure(4)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Linear')='Linear - Area vs. spool travel';
            map('Table1DAreaOpening')='Tabulated data - Area vs. spool travel';
            map('Table2DVolFlowOpeningPressure')='Tabulated data - Volumetric flow rate vs. spool travel and pressure drop';
            map('Table2DMassFlowOpeningPressure')='Tabulated data - Mass flow rate vs. spool travel and pressure drop';
        end
    end
end

