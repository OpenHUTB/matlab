



classdef SimulinkFunctionBlock<slci.simulink.SubSystemBlock

    methods

        function obj=SimulinkFunctionBlock(aBlk,aModel)
            obj=obj@slci.simulink.SubSystemBlock(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.SimulinkFunctionReturnTypeConstraint());
            obj.addConstraint(...
            slci.compatibility.SimulinkFunctionInportOutportConstraint());
            obj.addConstraint(...
            slci.compatibility.NestedSimulinkFunctionConstraint());
            obj.addConstraint(...
            slci.compatibility.SimulinkFunctionVariantConditionConstraint());
            obj.addConstraint(...
            slci.compatibility.SimulinkFunctionCallerPlacementConstraint());
        end
    end
end