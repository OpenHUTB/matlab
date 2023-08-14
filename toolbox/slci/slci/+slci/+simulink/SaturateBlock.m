


classdef SaturateBlock<slci.simulink.Block

    methods

        function obj=SaturateBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.UniformPortDataTypesConstraint);
            obj.updateConstraint(...
            slci.compatibility.SupportedPortDataTypesConstraint(...
            {'double','single','int8','uint8','int16',...
            'uint16','int32','uint32'}));
            obj.addConstraint(...
            slci.compatibility.RuntimeParamConstraint('UpperLimit'));
            obj.addConstraint(...
            slci.compatibility.RuntimeParamConstraint('LowerLimit'));
            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'RndMeth','Zero','Floor'));
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


