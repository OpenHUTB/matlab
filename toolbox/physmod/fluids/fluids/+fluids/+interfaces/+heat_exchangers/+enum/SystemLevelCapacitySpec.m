classdef SystemLevelCapacitySpec<int32





    enumeration
        HeatTransfer(1)
        OutletCondition(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('HeatTransfer')='Rate of heat transfer';
            map('OutletCondition')='Outlet condition';
        end
    end
end