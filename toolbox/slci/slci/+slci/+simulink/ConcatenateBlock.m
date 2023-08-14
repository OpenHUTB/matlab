



classdef ConcatenateBlock<slci.simulink.Block

    methods

        function obj=ConcatenateBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);

            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);

            obj.removeConstraint('BlockPortsMultiDim');
        end


        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
