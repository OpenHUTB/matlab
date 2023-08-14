



classdef MergeBlock<slci.simulink.Block

    methods

        function obj=MergeBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraint(...
            false,'AllowUnequalInputPortWidths','off'));
            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraint(...
            false,'InputPortOffsets','[]'));
            obj.addConstraint(...
            slci.compatibility.ParamValueConstraint('InitialOutput'));
            obj.addConstraint(...
            slci.compatibility.MergeSrcConstraint());
            obj.addConstraint(...
            slci.compatibility.MergeSrcPortConstraint());
            obj.addConstraint(...
            slci.compatibility.InitialConditionsConstraint('InitialOutput'));
            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
