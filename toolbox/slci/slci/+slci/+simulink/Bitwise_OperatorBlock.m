


classdef Bitwise_OperatorBlock<slci.simulink.Block

    methods

        function obj=Bitwise_OperatorBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);

            obj.addConstraint(...
            slci.compatibility.Bitwise_OperatorInportDimensionConstraint);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


