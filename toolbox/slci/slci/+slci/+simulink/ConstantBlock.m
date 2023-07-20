


classdef ConstantBlock<slci.simulink.Block

    methods

        function obj=ConstantBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.RuntimeParamConstraint('Value'));
            obj.setSupportsEnums(true);
            obj.setSupportsBuses(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
