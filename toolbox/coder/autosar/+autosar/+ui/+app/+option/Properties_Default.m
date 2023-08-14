



classdef Properties_Default<autosar.ui.app.base.OptionBase
    methods
        function obj=Properties_Default(env)





            id='Properties_Default';
            obj@autosar.ui.app.base.OptionBase(id,env);

            obj.Type='radio';
            obj.addOptionMessage();
            obj.Value='arxml';
            obj.Answer=true;
        end

        function out=isEnabled(obj)
            if obj.Env.IsSubComponent||~isempty(obj.Env.InterfaceDictName)


                out=false;
            else
                out=true;
            end
        end

        function ret=onNext(obj)
            if obj.Answer
                obj.Env.ImportProperties=false;
            end
            ret=0;
        end

        function msg=getHintMessage(obj)
            if obj.Answer
                msg=DAStudio.message('autosarstandard:ui:uiWizardDefaultPropertiesHelp');
            else
                msg=obj.HintMessage;
            end
        end
    end

    methods(Access=private)
        function result=isIncrementalMapping(~,env)
            result=false;


            if env.IsModelLinker
                linkingWizard=env.Manager.getModelLinkingWizard(env.CompBlkH);
                result=~isempty(linkingWizard.ValMsgs.warnings.ioWarn);
            end
        end

        function addOptionMessage(obj)
            if obj.isIncrementalMapping(obj.Env)
                obj.OptionMessage=DAStudio.message('autosarstandard:ui:uiWizardIncrementalProperties');
            else
                obj.OptionMessage=DAStudio.message('autosarstandard:ui:uiWizardDefaultProperties');
            end
        end
    end
end


