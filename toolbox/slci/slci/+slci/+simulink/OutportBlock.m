



classdef OutportBlock<slci.simulink.Block

    methods

        function obj=OutportBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            if strcmpi(get_param(aBlk,'Parent'),aModel.getName())
                obj.addConstraint(...
                slci.compatibility.NegativeBlockParameterConstraint(...
                true,'VarSizeSig','Yes'));
                obj.addConstraint(...
                slci.compatibility.NegativeBlockParameterConstraint(...
                false,'SignalType','complex'));
                obj.addConstraint(...
                slci.compatibility.NegativeBlockParameterConstraint(...
                false,'SamplingMode','Frame based'));
            else
                obj.addConstraint(...
                slci.compatibility.ParamValueConstraint('InitialOutput',...
                'ChkComplexParam'));

            end
            if slcifeature('BEPSupport')==0
                obj.addConstraint(...
                slci.compatibility.BusElementPortConstraint(...
                false,'IsBusElementPort','on'));
            end
            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'SourceOfInitialOutputValue','Dialog'));

            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraint(...
            false,'StorageClass','auto','SimulinkGlobal'));
            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);
            obj.setSupportsString(true)
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
