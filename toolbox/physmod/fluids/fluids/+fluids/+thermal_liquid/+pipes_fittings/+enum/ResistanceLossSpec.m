classdef ResistanceLossSpec<int32




    enumeration
        Constant(1)
        Table1DRe(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Constant')='Constant';
            map('Table1DRe')='Tabulated data - loss coefficient vs. Reynolds number';
        end
    end
end