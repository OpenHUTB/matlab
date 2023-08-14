



classdef SystemTargetFile_Classic<autosar.ui.app.base.OptionBase

    properties(Hidden,Constant)
        ID='SystemTargetFile_Classic';
    end

    methods
        function obj=SystemTargetFile_Classic(env)





            id='SystemTargetFile_Classic';
            obj@autosar.ui.app.base.OptionBase(id,env);

            obj.Type='radio';
            obj.OptionMessage=DAStudio.message('autosarstandard:ui:uiWizardSTFClassic');
            obj.Value='systemtargetfile';
            obj.Answer=~env.IsAdaptiveWizard;
        end

        function ret=onNext(obj)
            if obj.Answer
                activeConfigSet=autosar.utils.getActiveConfigSet(obj.Env.ModelHandle);
                set_param(activeConfigSet,'SystemTargetFile','autosar.tlc');
                obj.Env.IsAdaptiveWizard=false;
            end
            ret=0;
        end

        function msg=getHintMessage(obj)
            if obj.Answer
                msg=DAStudio.message('autosarstandard:ui:uiWizardSTFClassicHelp');
            else
                msg=obj.HintMessage;
            end
        end
    end
end


