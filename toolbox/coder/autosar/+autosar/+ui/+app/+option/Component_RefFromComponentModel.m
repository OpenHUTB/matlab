



classdef Component_RefFromComponentModel<autosar.ui.app.base.OptionBase

    properties(Hidden,Constant)
        ID='Component_RefFromComponentModel';
    end

    methods
        function obj=Component_RefFromComponentModel(env)





            id=autosar.ui.app.option.Component_RefFromComponentModel.ID;
            obj@autosar.ui.app.base.OptionBase(id,env);

            obj.Type='radio';
            obj.OptionMessage=DAStudio.message('autosarstandard:ui:uiWizardMapToSubComponent');
            obj.Value='ComponentPage';
            obj.Answer=false;
        end

        function out=isEnabled(~)
            out=true;
        end

        function ret=onNext(~)
            ret=0;
        end

        function msg=getHintMessage(obj)
            if obj.Answer
                msg=DAStudio.message('autosarstandard:ui:uiWizardMapToSubComponent');
            else
                msg=obj.HintMessage;
            end
        end
    end
end


