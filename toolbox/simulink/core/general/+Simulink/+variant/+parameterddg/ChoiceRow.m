classdef(Sealed=true,Hidden=true)ChoiceRow<handle








    properties(SetAccess=public,GetAccess=public)
        Condition char;
        Value;
    end

    properties(Hidden,Access=public)
        fDDGCreator Simulink.variant.parameterddg.VariantVariableDDGCreator;
    end

    methods
        function obj=ChoiceRow(aCondition,aValue,aDDGCreator)
            obj.Condition=aCondition;
            obj.Value=aValue;
            obj.fDDGCreator=aDDGCreator;
        end

        function isValid=isValidProperty(~,~)
            isValid=true;
        end

        function isReadOnly=isReadonlyProperty(~,~)
            isReadOnly=false;
        end

        function aPropValue=getPropValue(obj,aPropName)
            aPropValue=DAStudio.Protocol.getPropValue(obj,aPropName);
            if strcmp(aPropName,'Value')&&ischar(obj.Value)
                aPropValue=['''',aPropValue,''''];
            end
        end

        function updateProp(obj,aPropName,aPropValue,dlg)
            switch(aPropName)
            case 'Condition'
                obj.updateCondition(aPropValue);
            case 'Value'
                obj.evalAndSetValue(aPropValue,dlg)
                obj.updateValue();
            end
        end
    end

    methods(Access=private)
        function updateValue(obj)
            obj.fDDGCreator.updateChoice(obj.Condition,obj.Value);
        end

        function updateCondition(obj,aNewCondition)

            obj.fDDGCreator.addChoice(aNewCondition,obj.Value);


            obj.fDDGCreator.removeChoice(obj.Condition);


            obj.Condition=aNewCondition;
        end

        function evalAndSetValue(obj,aValueStr,dlg)






            evaluator=Simulink.variant.parameterddg.Evaluator(dlg.getContext);

            evaluatedValue=evaluator.evalin(aValueStr);
            obj.Value=evaluatedValue;
        end
    end
end


