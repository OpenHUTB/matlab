



classdef Component_Type<autosar.ui.app.base.OptionBase

    properties(Hidden,Constant)
        ID='Component_Type';
    end

    methods
        function obj=Component_Type(env)





            id=autosar.ui.app.option.Component_Type.ID;
            obj@autosar.ui.app.base.OptionBase(id,env);

            obj.OptionMessage=DAStudio.message('RTW:autosar:componentTypeStr');

            obj.Type='combobox';
            obj.Indent=1;

            obj.Value=autosar.composition.Utils.getSupportedComponentKinds();
            obj.DepInfo=struct('Option','Component_MapToComponent','Value',true);

            obj.Answer=obj.Value{1};
        end

        function out=isEnabled(obj)
            if obj.Env.IsSubComponent

                out=false;
            else
                out=true;
            end
        end

        function ret=onNext(obj)



            obj.Env.ComponentType=obj.Answer;
            ret=0;
        end

        function msg=getHintMessage(obj)
            if any(strcmp(obj.Answer,...
                autosar.composition.Utils.getSupportedComponentKinds()))
                msg=DAStudio.message(['autosarstandard:ui:uiWizard'...
                ,obj.Answer,'ComponentHelp']);
            else
                msg=obj.HintMessage;
            end
        end
    end
end


