


classdef ApplyFail<coder.internal.wizard.QuestionBase
    methods
        function obj=ApplyFail(env)
            id='ApplyFail';
            topic=message('RTW:wizard:Topic_Finish').getString;
            obj@coder.internal.wizard.QuestionBase(id,topic,env);

            obj.getAndAddOption(env,'Finish_ExtraStep');
            obj.HasHelp=false;
            obj.SinglePane=true;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
            obj.CountInProgress=false;
            obj.Topic=message('RTW:wizard:CodeGenFail').getString;
        end
        function out=getQuestionMessage(obj)
            msg1=['<p>',getQuestionMessage@coder.internal.wizard.QuestionBase(obj),'</p>'];
            msg2=message('RTW:wizard:Question_ApplyFail2').getString;
            out=obj.constructErrorText(msg1,msg2);
        end
        function onNext(obj)
            env=obj.Env;
            gui=env.Gui;
            gui.send_command('reset_log');
            gui.send_command('start_spin');
            try
                status=env.applyAndGenerate;
            catch e
                gui.send_command('stop_spin');
                gui.send_command('update_log',e.message);
                rethrow(e);
            end
            gui.send_command('stop_spin');
            obj.Options{1}.NextQuestion_Id=coder.internal.wizard.question.getNextQuestionIdFinish(status);
        end
    end
end
