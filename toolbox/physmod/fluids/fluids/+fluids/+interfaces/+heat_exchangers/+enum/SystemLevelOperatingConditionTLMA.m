classdef SystemLevelOperatingConditionTLMA<int32





    enumeration
        Cooling(1)
        Heating(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Cooling')='Heat transfer from thermal liquid to moist air';
            map('Heating')='Heat transfer from moist air to thermal liquid';
        end
    end
end