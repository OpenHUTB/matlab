classdef SystemLevelOperatingCondition2P2P<int32





    enumeration
        Cooling(1)
        Heating(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Cooling')='Heat transfer from two-phase fluid 1 to two-phase fluid 2';
            map('Heating')='Heat transfer from two-phase fluid 2 to two-phase fluid 1';
        end
    end
end