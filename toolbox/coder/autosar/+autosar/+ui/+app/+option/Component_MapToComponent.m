



classdef Component_MapToComponent<autosar.ui.app.base.OptionBase
    properties(Hidden,Constant)
        ID='Component_MapToComponent';
    end

    methods
        function obj=Component_MapToComponent(env)





            id=autosar.ui.app.option.Component_MapToComponent.ID;
            obj@autosar.ui.app.base.OptionBase(id,env);

            obj.Type='text';
            if obj.Env.IsAdaptiveWizard
                obj.OptionMessage=DAStudio.message('autosarstandard:ui:uiWizardMapToComponentAdaptive');
            else
                obj.OptionMessage=DAStudio.message('autosarstandard:ui:uiWizardMapToComponent');
                obj.Type='radio';
            end
            obj.Value='ComponentPage';
            obj.Answer=true;
        end

        function ret=onNext(~)
            ret=0;
        end

    end
end


