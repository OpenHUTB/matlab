

classdef ForIteratorBlock<slci.simulink.Block

    methods

        function obj=ForIteratorBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.RuntimeParamConstraint('IterationLimit'));

            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'IterationSource','internal'));

            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraint(...
            false,'IterationVariableDataType',...
            'int32','int16','int8','uint32','uint16','uint8'));

            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'ExternalIncrement','off'));

            obj.addConstraint(...
            slci.compatibility.ForIteratorIterationLimitConstraint);

        end


        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end