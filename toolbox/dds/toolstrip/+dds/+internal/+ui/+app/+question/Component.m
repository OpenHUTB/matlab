



classdef Component<dds.internal.ui.app.base.QuestionBase

    properties
        HelpViewID='DDS_Wizard_SetApplication';
    end

    methods
        function obj=Component(env)





            id='Component';
            topic=DAStudio.message('dds:toolstrip:uiWizardApplicationTopic');

            obj@dds.internal.ui.app.base.QuestionBase(id,topic,env);

            obj.NextQuestionId='Properties';

            obj.getAndAddOption('Component_Name');
            obj.getAndAddOption('Component_Vendor');

            obj.QuestionMessage=DAStudio.message('dds:toolstrip:uiWizardIntroduction');

            obj.HintMessage=DAStudio.message('dds:toolstrip:uiWizardDDSComponentHelp');
            obj.HasBack=false;
            obj.IsNextEnabled=true;
        end

        function onChange(obj)

            function ret=isvalid(appName)
                ret=false;
                if~isempty(appName)
                    splitStr=strsplit(appName,'/');
                    ret=all(cellfun(@iscvar,splitStr));
                end
            end


            env=obj.Env;


            if~isempty(env.LastAnswer)

                answers=env.LastAnswer.Value;


                obj.Options{1}.Value=answers(1).value;
                obj.IsNextEnabled=isvalid(obj.Options{1}.Value);

                propertiesQ=obj.Env.QuestionMap('Properties');
                propertiesQ.configureLookAndFeelForComponent();
            end

        end

    end
end


