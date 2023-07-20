


classdef WhileIteratorBlock<slci.simulink.Block

    methods


        function obj=WhileIteratorBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);

            obj.addConstraint(...
            slci.compatibility.NegativeBlockParameterConstraint(...
            false,'MaxIters','-1'));

            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraint(...
            false,'WhileBlockType','while'));
        end


        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end
end