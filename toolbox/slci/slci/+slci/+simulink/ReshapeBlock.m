


classdef ReshapeBlock<slci.simulink.Block

    methods

        function obj=ReshapeBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);

            obj.setSupportsEnums(true);
            obj.removeConstraint('BlockPortsMultiDim');
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


