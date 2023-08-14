classdef cgbLinearityWithSeparateCgb<int32




    enumeration
        instantly(1)
        gradually(2)
        separate(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('instantly')='physmod:ee:library:comments:enum:mosfet:cgbLinearityWithSeparateCgb:map_GateBulkAndGateSourceCapacitanceChangeInstantly';
            map('gradually')='physmod:ee:library:comments:enum:mosfet:cgbLinearityWithSeparateCgb:map_GateBulkAndGateSourceCapacitanceChangeGradually';
            map('separate')='physmod:ee:library:comments:enum:mosfet:cgbLinearityWithSeparateCgb:map_SeparateGateBulkAndGateSourceCapacitance';
        end
    end
end