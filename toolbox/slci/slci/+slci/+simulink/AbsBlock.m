


classdef AbsBlock<slci.simulink.Block

    methods

        function obj=AbsBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.UniformPortDataTypesConstraint);
            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'RndMeth','Zero','Floor'));
            obj.addConstraint(...
            slci.compatibility.SupportedPortDataTypesConstraint(...
            {'double','single','int8',...
            'uint8','int16','uint16',...
            'int32','uint32'}));
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


