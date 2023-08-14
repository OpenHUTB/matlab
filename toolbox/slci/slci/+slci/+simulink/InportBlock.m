



classdef InportBlock<slci.simulink.Block

    methods

        function obj=InportBlock(aBlk,aModel)
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
                obj.addConstraint(slci.compatibility.RootInportHasDstConstraint);
            end
            if slcifeature('BEPSupport')==0
                obj.addConstraint(slci.compatibility.BusElementPortConstraint(...
                false,'IsBusElementPort','on'));
            end
            obj.addConstraint(slci.compatibility.LatchInputParameterConstraint);
            obj.addConstraint(slci.compatibility.LatchInputForFeedbackSignalsConstraint);



            if slcifeature('VirtualBusSupport')==0&&...
                strcmpi(get_param(aBlk,'Parent'),aModel.getName())&&...
                strcmpi(get_param(aBlk,'UseBusObject'),'on')


                obj.addConstraint(...
                slci.compatibility.PositiveBlockParameterConstraintWithFix(...
                true,'BusOutputAsStruct','on'));
            end
            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);
            obj.setSupportsString(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

        function out=getVirtual(aObj)
            out=~strcmp(aObj.getParam('Parent'),aObj.ParentModel().getParam('Name'));
        end

    end

end
