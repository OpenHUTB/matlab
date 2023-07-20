


classdef CombinatorialLogicBlock<slci.simulink.Block

    methods

        function obj=CombinatorialLogicBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
        end

        function out=checkCombatibility(aObj)
            out=checkCombatibility@slci.simulink.Block(aObj);
        end

    end

end

