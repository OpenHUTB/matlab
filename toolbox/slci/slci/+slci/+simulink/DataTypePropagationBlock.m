


classdef DataTypePropagationBlock<slci.simulink.Block

    methods

        function obj=DataTypePropagationBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


