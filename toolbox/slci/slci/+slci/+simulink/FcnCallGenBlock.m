


classdef FcnCallGenBlock<slci.simulink.Block

    methods

        function obj=FcnCallGenBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'numberOfIterations','1'));
            obj.addConstraint(slci.compatibility.FcnCallGenNumDestinationsConstraint);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


