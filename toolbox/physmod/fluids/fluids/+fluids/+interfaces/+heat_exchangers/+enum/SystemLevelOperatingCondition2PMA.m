classdef SystemLevelOperatingCondition2PMA<int32





    enumeration
        Condenser(1)
        Evaporator(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Condenser')='Condenser - heat transfer from two-phase fluid to moist air';
            map('Evaporator')='Evaporator - heat transfer from moist air to two-phase fluid';
        end
    end
end