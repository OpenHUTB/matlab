



classdef Finish<dds.internal.ui.app.base.QuestionBase

    properties
        HelpViewID='DDS_Wizard_Finish';
    end

    methods
        function obj=Finish(env)





            id='Finish';
            topic=DAStudio.message('dds:toolstrip:uiWizardFinishTopic');

            obj@dds.internal.ui.app.base.QuestionBase(id,topic,env);

            obj.Options={};

            obj.DisplayFinishButton=true;

            obj.HasHelp=false;

            obj.QuestionMessage='';
        end

        function preShow(obj)
            env=obj.Env;
            if~env.ImportProperties
                outcome='1';
            else
                outcome='2';
            end
            obj.QuestionMessage=[DAStudio.message('dds:toolstrip:uiWizardFinish'),'<br>'...
            ,DAStudio.message(['dds:toolstrip:uiWizardNextSteps',outcome])];
        end
    end

end


