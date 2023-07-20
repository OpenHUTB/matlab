


classdef GainBlock<slci.simulink.Block

    methods

        function obj=GainBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.UniformPortDataTypesConstraint);
            obj.addConstraint(...
            slci.compatibility.RuntimeParamConstraint('Gain'));
            obj.addConstraint(...
            slci.compatibility.GainParamDataTypeConstraint());
            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'RndMeth','Zero','Floor'));

            if(~strcmp(get_param(aBlk,'Multiplication'),'Element-wise(K.*u)'))
                obj.addConstraint(...
                slci.compatibility.SupportedOutPortDataTypesConstraint({'double','single'}));
            end

        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


