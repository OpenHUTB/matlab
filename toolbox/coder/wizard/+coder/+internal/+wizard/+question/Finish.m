


classdef Finish<coder.internal.wizard.QuestionBase
    methods
        function obj=Finish(env)
            id='Finish';
            topic=message('RTW:wizard:Topic_Finish').getString;
            obj@coder.internal.wizard.QuestionBase(id,topic,env);
            obj.getAndAddOption(env,'Finish_ExtraStep');
            obj.HasHelp=false;
            obj.SinglePane=true;
            obj.DisplayConfigDiff=true;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
        end
        function preShow(obj)
            preShow@coder.internal.wizard.QuestionBase(obj);
            env=obj.Env;
            if env.isSubsystemBuild
                system=[message('RTW:wizard:subsystem').getString,': ''',env.SourceSubsystem,''''];
            else
                system=[message('RTW:wizard:model').getString,': ''',env.ModelName,''''];
            end

            obj.QuestionMessage=message('RTW:wizard:Question_Finish',system).getString;
            if~isempty(env.SubModels)
                warning_msg=['<div class="warning">'...
                ,env.Gui.getWarningImage,' '...
                ,message('RTW:wizard:WarnMdlRef').getString,'</div>'
                ];
                obj.QuestionMessage=[obj.QuestionMessage,warning_msg];
            end
        end
        function onNext(obj)
            env=obj.Env;
            gui=env.Gui;
            gui.send_command('reset_log');
            gui.send_command('start_spin');
            try
                obj.warnIfModified();
                obj.warnIfWorkspaceCSRef();
                status=env.applyAndGenerate;
            catch e
                gui.send_command('stop_spin');
                gui.send_command('update_log',e.message);
                rethrow(e);
            end
            gui.send_command('stop_spin');
            obj.Options{1}.NextQuestion_Id=coder.internal.wizard.question.getNextQuestionIdFinish(status);
        end
        function warnIfWorkspaceCSRef(obj)
            env=obj.Env;
            errId='RTW:wizard:WarnModelUsesWorkSpaceCSRefLostChanges';
            oldCS=env.CSM.getOldConfigSet(env.ModelName);
            if isa(oldCS,'Simulink.ConfigSetRef')&&...
                strcmp(oldCS.getSourceLocation,'Base Workspace')
                warnMsg=message(errId,env.ModelName);
                MSLE=MSLException(get_param(env.ModelName,'Handle'),warnMsg);
                env.handle_warning(MSLE);
                env.displayMSV();
            end
        end
        function warnIfModified(obj)
            env=obj.Env;
            errId='RTW:wizard:WarnModelIsDirtyBeforeCodeGen';
            if env.AnalysisTimeStamp~=get_param(env.ModelName,'RTWModifiedTimeStamp')
                warnMsg=message(errId,env.ModelName);
                MSLE=MSLException(get_param(env.ModelName,'Handle'),warnMsg);
                env.handle_warning(MSLE);
                env.displayMSV();
            end
        end
    end
end
