

classdef PolyvalBlock<slci.simulink.Block

    methods

        function obj=PolyvalBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.UniformPortDataTypesConstraint);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end

