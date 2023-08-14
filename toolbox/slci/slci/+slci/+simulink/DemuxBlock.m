


classdef DemuxBlock<slci.simulink.Block

    methods

        function obj=DemuxBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.VirtualBlockOutportResolvedSignalConstraint);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
