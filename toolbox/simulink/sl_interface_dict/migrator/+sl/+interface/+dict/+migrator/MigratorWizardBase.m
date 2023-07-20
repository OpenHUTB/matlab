



classdef MigratorWizardBase<sl.interface.dict.migrator.base.GuiBase


    properties
        QFlags;
        ValMsgs;
    end

    properties(Constant,Access=public)
        Title=DAStudio.message('interface_dictionary:migrator:uiMigratorWizardTitle');
    end

    methods
        function env=MigratorWizardBase()


            ID='/dictionary-migrator/wizard';
            env.Gui=sl.interface.dict.migrator.base.Gui(env,ID,env.GuiTag,env.Title);
        end

        function delete(env)



            if~env.IsWizardFinished
                env.cleanupOnPrematureClose;
            end
        end

        function start(env)
            env.init();
        end

    end

    methods(Access=public)
        function setWizardQuestions(env,lastQuestionId)

            env.QuestionMap=containers.Map;
            env.OptionMap=containers.Map;



            qObjs=struct;

            qObjs.MigratorMainPageQ=sl.interface.dict.migrator.question.MigratorMainPage(env);

            if~isempty(env.ValMsgs.flags.Conflicts)
                qObjs.MigratorConflictsQ=sl.interface.dict.migrator.question.MigratorConflicts(env);
            end


            if~isempty(lastQuestionId)
                if isfield(qObjs,'MigratorConflictsQ')
                    qObjs.MigratorConflictsQ.updateNextQuestionInfo(lastQuestionId,false);
                else
                    qObjs.MigratorMainPageQ.updateNextQuestionInfo(lastQuestionId,false);
                end
            end



            qObjs=struct2cell(qObjs);
            env.CurrentQuestion=qObjs{1};
        end
    end

    methods(Access=protected)


        function init(env)
            setWizardQuestions(env,'');
        end

        function cleanupOnPrematureClose(~)
        end
    end
end
