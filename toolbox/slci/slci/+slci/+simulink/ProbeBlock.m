


classdef ProbeBlock<slci.simulink.Block

    methods

        function obj=ProbeBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.ProbeOutDataTypeConstraint());
            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
