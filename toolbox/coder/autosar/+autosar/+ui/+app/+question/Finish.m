



classdef Finish<autosar.ui.app.base.QuestionBase

    properties
        HelpViewID='autosar_build_component_finish';
    end

    methods
        function obj=Finish(env)





            id='Finish';
            topic=DAStudio.message('autosarstandard:ui:uiWizardFinishTopic');

            obj@autosar.ui.app.base.QuestionBase(id,topic,env);

            obj.Options={};

            obj.DisplayFinishButton=true;

            obj.HasHelp=false;

            obj.QuestionMessage='';
        end

        function preShow(obj)
            env=obj.Env;
            if~env.ImportProperties
                if env.DefaultMapping
                    outcome='1';
                else
                    outcome='2';
                end
            else
                if env.DefaultMapping
                    outcome='3';
                else
                    outcome='4';
                end
            end
            obj.QuestionMessage=[DAStudio.message('autosarstandard:ui:uiWizardFinish'),'<br>'...
            ,DAStudio.message(['autosarstandard:ui:uiWizardNextSteps',outcome])];


            activeConfigSet=autosar.utils.getActiveConfigSet(env.ModelHandle);
            if strcmp(get_param(activeConfigSet,'SolverType'),'Variable-step')
                warningMsg=DAStudio.message('RTW:wizard:WarnVariableStepSolver');
                obj.addWarningToQuestionMessage(warningMsg);
            end
        end

        function addWarningToQuestionMessage(obj,warningMsg)
            obj.QuestionMessage=[obj.QuestionMessage,'<br><p style="color:#CA6F1E;font-size:12px;">',warningMsg,'</p>'];
        end
    end
end


