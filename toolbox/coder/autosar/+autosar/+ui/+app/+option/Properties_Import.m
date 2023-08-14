



classdef Properties_Import<autosar.ui.app.base.OptionBase
    methods
        function obj=Properties_Import(env)





            id='Properties_Import';
            obj@autosar.ui.app.base.OptionBase(id,env);

            obj.Type='radio';
            obj.OptionMessage=DAStudio.message('autosarstandard:ui:uiWizardImportProperties');
            obj.Value='arxml';
            obj.Answer=false;
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
                obj.Env.ImportProperties=true;
                obj.Env.DefaultMapping=false;
            end
            ret=0;
        end

        function msg=getHintMessage(obj)
            if obj.Answer
                msg=DAStudio.message('autosarstandard:ui:uiWizardImportPropertiesHelp');
            else
                msg=obj.HintMessage;
            end
        end
    end
end


