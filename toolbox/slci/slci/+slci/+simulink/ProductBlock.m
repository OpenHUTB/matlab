


classdef ProductBlock<slci.simulink.Block

    methods

        function obj=ProductBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.UniformPortDataTypesConstraint);







            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'RndMeth','Zero','Floor'));
            if(strcmp(get_param(aBlk,'Multiplication'),'Matrix(*)'))
                obj.addConstraint(...
                slci.compatibility.SupportedOutPortDataTypesConstraint(...
                {'uint8','int8',...
                'uint16','int16',...
                'uint32','int32',...
                'double','single'}));


                obj.addConstraint(slci.compatibility.PositiveBlockParameterConstraintWithFix(...
                false,'SaturateOnIntegerOverflow','off'));
                obj.addConstraint(...
                slci.compatibility.PositiveBlockParameterConstraint(...
                false,'inputs','2','**','/*','*/','//','/'));
            else
                obj.addConstraint(...
                slci.compatibility.ProductBlockNegativeParameterConstraint(...
                false,'inputs'));
            end

            multi=get_param(aBlk,'Multiplication');
            if strcmpi(multi,'Matrix(*)')
                obj.addConstraint(...
                slci.compatibility.BlockConstantSampleTimeConstraint);
                obj.addConstraint(...
                slci.compatibility.SameValueConstantInputConstraint);
            end
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


