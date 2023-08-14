classdef faultInputCondition<int32


    enumeration
        greaterThan(1)
        lessThan(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('greaterThan')='physmod:ee:library:comments:enum:faults:faultInputCondition:map_GreaterThan';
            map('lessThan')='physmod:ee:library:comments:enum:faults:faultInputCondition:map_LessThan';
        end
    end
end
