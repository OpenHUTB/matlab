


classdef DataTypeDuplicateBlock<slci.simulink.Block

    methods

        function obj=DataTypeDuplicateBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel)
            obj.setSupportsEnums(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
