

classdef InitialConditionBlock<slci.simulink.Block

    methods

        function obj=InitialConditionBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.RuntimeParamConstraint('Value'));
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


