



classdef Component<autosar.ui.app.base.QuestionBase

    properties
        HelpViewID='autosar_build_component_swc_details';
    end

    methods
        function obj=Component(env)





            id='Component';
            topic=DAStudio.message('autosarstandard:ui:uiWizardComponentTopic');

            obj@autosar.ui.app.base.QuestionBase(id,topic,env);

            if env.IsAdaptiveWizard
                obj.NextQuestionId='Finish';
            else
                obj.NextQuestionId='Properties';
            end

            obj.getAndAddOption('Component_MapToComponent');
            obj.getAndAddOption('Component_Name');
            obj.getAndAddOption('Component_Pkg');
            if~env.IsAdaptiveWizard
                obj.getAndAddOption('Component_Type');
                if~env.IsModelLinker
                    obj.getAndAddOption('Component_RefFromComponentModel');
                end
            end

            obj.QuestionMessage=DAStudio.message('autosarstandard:ui:uiWizardIntroduction');

            obj.HintMessage=DAStudio.message('autosarstandard:ui:uiWizardComponentHelp');



            if env.IsModelLinker
                obj.HasBack=true;
            else
                obj.HasBack=env.NeedSTFSelectionDialog;
            end
        end

        function onChange(obj)



            env=obj.Env.setEnvironmentForQuestionMap;


            if~isempty(env.LastAnswer)

                answers=env.LastAnswer.Value;


                if env.IsAdaptiveWizard



                    obj.Options{2}.Value=answers{2}.value;
                    obj.Options{3}.Value=answers{3}.value;
                else
                    obj.Options{1}.Answer=answers(1).value;
                    obj.Options{2}.Value=answers(2).value;
                    obj.Options{3}.Value=answers(3).value;
                    obj.Options{4}.Answer=answers(4).value;

                    if env.IsModelLinker


                        obj.Env.IsSubComponent=false;
                    else
                        obj.Options{5}.Answer=answers(5).value;

                        mapToSubCompOption=obj.Options(cellfun(@(x)strcmp(x.Id,...
                        'Component_RefFromComponentModel'),obj.Options));
                        assert(~isempty(mapToSubCompOption),...
                        'Could not find option with id Component_RefFromComponentModel');
                        obj.Env.IsSubComponent=mapToSubCompOption{1}.Answer;
                    end



                    propertiesQ=obj.Env.QuestionMap('Properties');
                    if obj.Env.IsSubComponent
                        propertiesQ.configureLookAndFeelForSubComponent();
                    else
                        propertiesQ.configureLookAndFeelForComponent();
                    end
                end
            end
        end
    end
end


