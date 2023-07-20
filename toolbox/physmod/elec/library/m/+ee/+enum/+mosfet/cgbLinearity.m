classdef cgbLinearity<int32



    enumeration
        instantly(1)
        gradually(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('instantly')='physmod:ee:library:comments:enum:mosfet:cgbLinearity:map_GateBulkAndGateSourceCapacitanceChangeInstantly';
            map('gradually')='physmod:ee:library:comments:enum:mosfet:cgbLinearity:map_GateBulkAndGateSourceCapacitanceChangeGradually';
        end
    end
end