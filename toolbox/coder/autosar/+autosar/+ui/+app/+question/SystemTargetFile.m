



classdef SystemTargetFile<autosar.ui.app.base.QuestionBase

    properties
        HelpViewID='autosar_build_component_stf_selection';
    end

    methods
        function obj=SystemTargetFile(env)





            id='SystemTargetFile';
            topic=DAStudio.message('autosarstandard:ui:uiWizardSTFTopic');

            obj@autosar.ui.app.base.QuestionBase(id,topic,env);

            obj.NextQuestionId='Component';

            obj.getAndAddOption('SystemTargetFile_Classic');
            obj.getAndAddOption('SystemTargetFile_Adaptive');

            obj.QuestionMessage=DAStudio.message('autosarstandard:ui:uiWizardAutosarSTF');
            obj.HintMessage=DAStudio.message('autosarstandard:ui:uiWizardAutosarSTFHelp');
            obj.HasBack=false;
        end

        function onChange(obj)

            env=obj.Env;

            if~isempty(env.LastAnswer)&&isa(env.LastAnswer.Value,'struct')
                answers=env.LastAnswer.Value;

                obj.Options{1}.Answer=answers(1).value;
                obj.Options{2}.Answer=answers(2).value;
            end
        end

        function ret=onNext(obj)

            for i=1:length(obj.Options)
                ret=obj.Options{i}.applyOnNext();
                if ret<0
                    return
                end
            end

            if obj.Env.IsAdaptiveWizard


                obj.Env.repopulateQuestionsForAdaptiveSTFSelection();
            end
            ret=0;
        end
    end
end



