



classdef Properties_Dictionary<dds.internal.ui.app.base.OptionBase
    methods
        function obj=Properties_Dictionary(env)





            id='Properties_Dictionary';
            obj@dds.internal.ui.app.base.OptionBase(id,env);

            obj.Type='radio';
            obj.OptionMessage=DAStudio.message('dds:toolstrip:uiWizardDictionaryProperties');
            obj.Value='xml';
            obj.Answer=true;
        end

        function out=isEnabled(obj)
            out=true;
        end

        function ret=onNext(obj)
            if obj.Answer
                obj.Env.ImportProperties=false;
            end
            ret=0;
        end

        function msg=getHintMessage(obj)
            if obj.Answer
                msg=DAStudio.message('dds:toolstrip:uiWizardDictionaryPropertiesHelp');
            else
                msg=obj.HintMessage;
            end
        end
    end
end


