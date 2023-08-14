

classdef DotProductBlock<slci.simulink.Block

    methods

        function obj=DotProductBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.updateConstraint(...
            slci.compatibility.SupportedPortDataTypesConstraint(...
            {'double','single'}));

            obj.addConstraint(...
            slci.compatibility.UniformPortDataTypesConstraint);
            obj.addConstraint(...
            slci.compatibility.BlockConstantSampleTimeConstraint);
            obj.addConstraint(...
            slci.compatibility.SameValueConstantInputConstraint);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end

