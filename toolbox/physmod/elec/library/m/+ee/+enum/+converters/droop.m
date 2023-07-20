classdef droop<int32



    enumeration
        value(1)
        percent(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('value')='physmod:ee:library:comments:enum:converters:droop:map_Value';
            map('percent')='physmod:ee:library:comments:enum:converters:droop:map_Percent';
        end
    end
end
