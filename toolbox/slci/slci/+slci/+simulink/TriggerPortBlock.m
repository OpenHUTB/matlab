

classdef TriggerPortBlock<slci.simulink.Block

    methods

        function obj=TriggerPortBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addCommonContraints();
            triggerType=obj.getParam('TriggerType');
            if strcmpi(triggerType,'function-call')
                obj.addFunctioncallPortConstraints();
            else
                obj.addTriggerPortConstraints();
            end


            obj.addConstraint(...
            slci.compatibility.ConstantPortConstraint('Trigger',1));
            obj.addConstraint(...
            slci.compatibility.SupportedOutPortDataTypesConstraint({...
            'double','int8'}));
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

    methods(Access=private)

        function addCommonContraints(obj)
            obj.addConstraint(slci.compatibility.ScalarTriggerPortConstraint());
        end

        function addTriggerPortConstraints(obj)
            obj.addConstraint(slci.compatibility.BooleanTriggerPortConstraint());
            obj.addConstraint(slci.compatibility.RootTriggerPortConstraint());


            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(...
            false,'InitialTriggerSignalState',...
            'compatibility (no trigger on first evaluation)'));
        end

        function addFunctioncallPortConstraints(obj)
            obj.addConstraint(...
            slci.compatibility.NegativeBlockParameterConstraint(...
            false,'StatesWhenEnabling','inherit'));
        end

    end

end
