classdef faultsFourTerminals<int32



    enumeration
        open(1)
        bulkShort(2)
        gateShort(3)
        parameter(4)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('open')='physmod:ee:library:comments:enum:mosfet:faultsFourTerminals:map_Open';
            map('bulkShort')='physmod:ee:library:comments:enum:mosfet:faultsFourTerminals:map_DrainBulkShortOrSourceBulkShort';
            map('gateShort')='physmod:ee:library:comments:enum:mosfet:faultsFourTerminals:map_GateOxideShort';
            map('parameter')='physmod:ee:library:comments:enum:mosfet:faultsFourTerminals:map_ParameterShift';
        end
    end
end