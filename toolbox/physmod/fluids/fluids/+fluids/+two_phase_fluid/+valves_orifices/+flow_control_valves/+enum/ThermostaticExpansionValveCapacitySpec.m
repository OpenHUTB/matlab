classdef ThermostaticExpansionValveCapacitySpec<int32





    enumeration
        HeatTransfer(1)
        MassFlowRate(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('HeatTransfer')='Evaporator heat transfer';
            map('MassFlowRate')='Mass flow rate';
        end
    end
end