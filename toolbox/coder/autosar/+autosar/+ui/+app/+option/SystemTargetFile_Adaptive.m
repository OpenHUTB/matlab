



classdef SystemTargetFile_Adaptive<autosar.ui.app.base.OptionBase

    properties(Hidden,Constant)
        ID='SystemTargetFile_Adaptive';
    end

    methods
        function obj=SystemTargetFile_Adaptive(env)





            id='SystemTargetFile_Adaptive';
            obj@autosar.ui.app.base.OptionBase(id,env);

            obj.Type='radio';
            obj.OptionMessage=DAStudio.message('autosarstandard:ui:uiWizardSTFAdaptive');
            obj.Value='systemtargetfile';
            obj.Answer=env.IsAdaptiveWizard;
        end

        function out=isEnabled(obj)
            if~isempty(obj.Env.InterfaceDictName)


                out=false;
            else
                out=true;
            end
        end

        function ret=onNext(obj)
            if obj.Answer
                activeConfigSet=autosar.utils.getActiveConfigSet(obj.Env.ModelHandle);
                set_param(activeConfigSet,'SystemTargetFile','autosar_adaptive.tlc');
                obj.Env.IsAdaptiveWizard=true;
            end
            ret=0;
        end

        function msg=getHintMessage(obj)
            if obj.Answer
                msg=DAStudio.message('autosarstandard:ui:uiWizardSTFAdaptiveHelp');
            else
                msg=obj.HintMessage;
            end
        end
    end
end


