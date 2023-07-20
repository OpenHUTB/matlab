classdef SystemLevelOperatingCondition2PTL<int32





    enumeration
        Condenser(1)
        Evaporator(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Condenser')='Condenser - heat transfer from two-phase fluid to thermal liquid';
            map('Evaporator')='Evaporator - heat transfer from thermal liquid to two-phase fluid';
        end
    end
end